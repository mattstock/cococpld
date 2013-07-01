#include "rom.h"
#include "busio.h"
#include "fdc.h"
#include "firmware2.h"

/*
	DMK disk format
	byte 0 - 0x00 R/W, 0xFF RO
	1 - track count (0x23, 0x28) 
	2/3 - track length, little endian (typically 0x1900)
	4 - options (density ignore, single density, x, single sided, x, x, x, x) (0x10)
	5-f - 0x00

	Track header:

	Each side of each track has a 128 (80H) byte header which contains an offset pointer to each IDAM in the track.
	This allows a maximum of 64 sector IDAMs/track. This is more than twice what an 8 inch disk would require and 3.5 
	times that of a normal TRS-80 5 inch DD disk. This should more than enough for any protected disk also.

	These IDAM pointers MUST adhere to the following rules.

	Each pointer is a 2 byte offset to the FEh byte of the IDAM. In double byte single density the pointer is to the first FEh.
	The offset includes the 128 byte header. For example, an IDAM 10h bytes into the track would have a pointer of 90h, 10h+80h=90h.
	The IDAM offsets MUST be in ascending order with no unused or bad pointers.
	If all the entries are not used the header is terminated with a 0000h entry. Unused entries must also be zero filled..
	Any IDAMs overwritten during a sector write command should have their entry removed from the header and all other pointer entries shifted to fill in.
	The IDAM pointers are created during the track write command (format). A completed track write MUST remove all previous IDAM pointers. 
	A partial track write (aborted with the forced interrupt command) MUST have it's previous pointers that were not overwritten added to the new IDAM pointers.
	The pointer bytes are stored in reverse order (LSB/MSB).

	Each IDAM pointer has two flags. Bit 15 is set if the sector is double density. Bit 14 is currently undefined. These bits must 
	be masked to get the actual sector offset. For example, an offset to an IDAM at byte 90h would be 0090h if single density and 8090h if double density.

	Track data:

	The actual track data follows the header and can be viewed with a hex editor showing the raw data on the track. If the virtual 
	disk doesn't have bits 6 or 7 set of byte 4 of the disk header then each single density data byte is written twice, this includes IDAMs 
	and CRCs (the CRCs are calculated as if only 1 byte was written however). The IDAM and sector data each have CRCs, this is just like on a real disk.

	Modification should not be done since doing so without updating  the CRCs would cause data errors. Modification could be done 
	however to create protected tracks for importing protected disks to virtual disk format. Examples of disks created using this 
	technique are "Super Utility+ 3.0" and "Forbidden City".
 */

// Wait until the DRO bit changes to 0
void waitDR() {
	while (reg[RW(FDCSTAT)] & 0x02)
	loadRegisters();
}

// Given a logical sector and track, find and return the
// file position of the start of the physical sector.
uint32_t findSector(File file, uint32_t tracklen, uint8_t trackcnt, uint8_t track, uint8_t sector) {
	uint32_t pos;
	uint32_t off;
	uint8_t cnt;
	
	pos = 0x10 + tracklen*track;
	
	Serial.print("findSector(");
	Serial.print(track, HEX);
	Serial.print(",");
	Serial.print(sector, HEX);
	Serial.print(") = ");
	Serial.println(pos, HEX);

	file.seek(pos);
	off = file.read();
	off += ((0x3f & file.read()) << 8);
	cnt = 0;
	while (off != 0) {
		Serial.print("Looking at ");
		Serial.println(pos+off+3, HEX);
		file.seek(pos+off+3);
		if (file.read() == sector) {
			Serial.print("Found sector at ");
			Serial.println(cnt, HEX);
			return pos+off+0x2d;
		}
		cnt++;
		file.seek(pos+2*cnt);
		off = file.read();
		off += ((0x3f & file.read()) << 8);
	}
	Serial.println("failure!");
	return 0;
}

// Start to handle FDC instructions
void fdc() {
	File image;
	uint8_t command = 0;
	uint8_t drive = 100;
	uint8_t ddir = 0;
	uint8_t control = 0;
	uint8_t sector = 1;
	uint8_t track = 0;
	uint32_t tmp;
	
	// pulled from DMK header
	uint16_t tracklen;
	uint8_t trackcnt;
	
	// Set reset register values for FDC
	setRegister(RW(DSKREG), 0x00);
	setRegister(RW(FDCSTAT), 0x04);
	setRegister(RR(FDCTRK), 0x00); // track 0
	setRegister(RW(FDCTRK), 0x00);
	setRegister(RR(FDCSEC), 0x01); // sector 1
	setRegister(RW(FDCSEC), 0x01);

	lcd.clear();
	lcd.print("FDC ready");
	while (lcd.readButtons());
	while (!lcd.readButtons()) {
		if (digitalRead(WRITEINT_PIN)) {
			loadRegisters();
			
			if (control != reg[RR(DSKREG)]) {
				Serial.println("Control register update");

				control = reg[RR(DSKREG)];
				if (!(control & 0x47)) {
					Serial.println("closing open floppy");
					drive = 100;
					image.close();
				}
				if ((control & 0x01) && (drive != 0)) {
					drive = 0;
					image.close();
					image = SD.open("floppy0.dsk", FILE_WRITE);
					image.seek(1);
					trackcnt = image.read();
					tracklen = image.read();
					tracklen += (image.read() << 8);
					
					Serial.print("Open f0(");
					Serial.print(trackcnt, HEX);
					Serial.print(",");
					Serial.print(tracklen, HEX);
					Serial.println(")");
					
					track = 0;
					sector = 1;
				}
			}
			
			if (command == reg[RR(FDCCMD)])
			continue;
			
			command = reg[RR(FDCCMD)];
			switch (reg[RR(FDCCMD)]) {
				case 0x03: // RESTORE
					Serial.println("RESTORE");
					setRegister(RW(FDCSTAT), 0x04);
					setRegister(RR(FDCTRK), 0x00); // track 0
					setRegister(RW(FDCTRK), 0x00);
					setRegister(RR(FDCSEC), 0x01); // sector 1
					setRegister(RW(FDCSEC), 0x01);
					track = 0;
					sector = 1;
					setNMI(true);
					break;
				case 0x17: // SEEK
					setRegister(RW(FDCSTAT), (track ? 0x01 : 0x05)); // BUSY;
					Serial.print("SEEK ");
					track = reg[RR(FDCDAT)];
					Serial.println(track, HEX);
					setRegister(RW(FDCTRK), track);
					setRegister(RW(FDCSTAT), (track ? 0x04 : 0x00)); // Set track 0;
					setNMI(true);
					break;
				case 0x23: // STEP
					setRegister(RW(FDCSTAT), (track ? 0x21 : 0x25)); // BUSY;
					Serial.print("STEP ");
					if (ddir)
						track++;
					else
						track--;
					Serial.println(track, HEX);
					if (track == 255)
						track = 0;
					setRegister(RW(FDCSTAT), (track ? 0x24 : 0x20));
					setNMI(true);
					break;
				case 0x43: // STEP IN
					setRegister(RW(FDCSTAT), 0x21); // BUSY
					Serial.print("STEP IN ");
					track--;
					ddir = 0;
					if (track == 255)
						track = 0;
					setRegister(RW(FDCSTAT), (track ? 0x24 : 0x20));
					Serial.println(track, HEX);
					setNMI(true);
					break;
				case 0x53: // STEP OUT
					setRegister(RW(FDCSTAT), 0x21); // BUSY
					Serial.print("STEP OUT ");
					track++;
					ddir = 1;
					Serial.println(track, HEX);
					setRegister(RW(FDCSTAT), 0x20);
					setNMI(true);
					break;
				case 0x80: // READ SECTOR
				setRegister(RW(FDCSTAT), 0x01); // BUSY
				sector = reg[RR(FDCSEC)];
				tmp = findSector(image, tracklen, trackcnt, track, sector);
				Serial.print("pos = ");
				Serial.println(tmp, HEX);
				image.seek(tmp);
				Serial.print("READ SECTOR ");
				Serial.println(sector, HEX);
				
				for (int i = 0; i < 256; i++) {
					setRegister(RW(FDCDAT), image.read());
					setRegister(RW(FDCSTAT), 0x03);
					if (i != 255) {
						setHALT(false);
						waitDR();
					}
				}
				
				setRegister(RW(FDCSTAT), 0x00);
				setNMI(true);
				break;
				case 0xa0: // WRITE SECTOR
				setRegister(RW(FDCSTAT), 0x01); // BUSY
				sector = reg[RR(FDCSEC)];
				image.seek(findSector(image, tracklen, trackcnt, track, sector));
				Serial.print("WRITE SECTOR ");
				Serial.println(sector, HEX);
				
				for (int i=0; i < 256; i++) {
					setRegister(RW(FDCSTAT), 0x03);
					setHALT(false);
					waitDR();
					image.write(reg[RR(FDCDAT)]);
				}
				
				setRegister(RW(FDCSTAT), 0x00);
				setNMI(true);
				break;
				case 0xc0: // READ ADDRESS
				setRegister(RW(FDCSTAT), 0x01); // BUSY
				Serial.print("READ ADDRESS ");
				Serial.print(track);
				Serial.print("/");
				Serial.println(sector);

				setRegister(RW(FDCSTAT), 0x03); // BUSY, DRO
				setRegister(RW(FDCDAT), track);
				setHALT(false);
				delay(5);
				setRegister(RW(FDCDAT), 0x00);
				setHALT(false);
				delay(5);
				setRegister(RW(FDCDAT), sector);
				setHALT(false);
				delay(5);
				setRegister(RW(FDCDAT), 0x01);
				setHALT(false);
				delay(5);
				setRegister(RW(FDCDAT), 0x00); // CRC1
				setHALT(false);
				delay(5);
				setRegister(RW(FDCDAT), 0x00); // CRC2
				setRegister(RW(FDCSTAT), 0x00); // clear BUSY
				setNMI(true);
				break;
				case 0xe4: // READ TRACK
				Serial.println("READ TRACK");
				setNMI(true);
				break;
				case 0xf4: // WRITE TRACK
/*				setRegister(RW(FDCSTAT), RW(FDCSTAT) | 0x01); // BUSY
				Serial.print("WRITE TRACK ");
				Serial.println(track, HEX);
				image.seek(track*TRACKSIZE);
				
				for (uint16_t i=0; i < TRACKSIZE; i++) {
					switch (reg[RR(FDCDAT)]) {
						case 0xf5:
						image.write(0xf5);
						crc = 0xffff;
						break;
						case 0xf7:
						image.write((crc >> 8) & 0xff);
						image.write(crc & 0xff);
						break;
						default:
						image.write(reg[RR(FDCDAT)]);
						for (int i = 0; i < 8; i++)
						crc = (crc << 1) ^ ((((crc >> 8) ^ ((reg[RR(FDCDAT)]) << i)) & 0x0080) ? 0x1021 : 0);
						break;
					}
					setRegister(RW(FDCSTAT), 0x03);
					setHALT(false);
					waitDR();
				}
				
				setRegister(RW(FDCSTAT), 0x00); */
				setNMI(true); // command complete
				break;
				case 0xd0: // FORCE INTERRUPT
				Serial.println("FORCE INT");
				setRegister(RW(FDCSTAT), (track ? 0x00 : 0x04));
				setNMI(true);
				break;
			}
			
			if (reg[RR(FDCCMD)] != 0xf4) {
				Serial.print("Command: ");
				Serial.print(reg[RR(FDCCMD)], HEX);
				Serial.print(" Status: ");
				Serial.print(reg[RW(FDCSTAT)], HEX);
				Serial.print(" Track: ");
				Serial.print(reg[RR(FDCTRK)], HEX);
				Serial.print("/");
				Serial.print(reg[RW(FDCTRK)], HEX);
				Serial.print(" Sector: ");
				Serial.print(reg[RR(FDCSEC)], HEX);
				Serial.print("/");
				Serial.print(reg[RW(FDCSEC)], HEX);
				Serial.print(" Data: ");
				Serial.print(reg[RR(FDCDAT)], HEX);
				Serial.print("/");
				Serial.print(reg[RW(FDCDAT)], HEX);
				Serial.print(" diskreg = ");
				Serial.println(reg[RR(DSKREG)], HEX);
			}

		}
	}
	image.close();
	delay(2000);
}
