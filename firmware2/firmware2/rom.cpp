#include "rom.h"
#include "busio.h"
#include "firmware2.h"
#include "error.h"

uint8_t reg[30];

void verifyROM(File dataFile) {
	uint16_t address;
	uint8_t stored;
	uint8_t disk;
	lcd.clear();

	if (!dataFile) {
		displayMsg(OPEN_FAILED);
		return;
	}
	
	if (dataFile.size() <= 16*1024)
		address = 0xc000;
	else
		address = 0x8000;
	while (dataFile.available()) {
		disk = dataFile.read();
  		setAddress(address);
		
		if (address % 0x100 == 0) {
			lcd.clear();
			lcd.print(address, HEX);
		}
		stored = readData();
		if (stored != disk) {
			lcd.clear();
			lcd.print(address, HEX);
			lcd.print(": ");
			lcd.print(stored, HEX);
			lcd.print(" != ");
			lcd.print(disk, HEX);
			delay(200);
		}
		address++;
	}
	
	dataFile.close();

	lcd.clear();
	displayMsg(VERIFY);
	displayMsg(COMPLETE);
	delay(2000);
}

void eraseROM() {			
	lcd.clear();
	displayMsg(ERASE);

	uint16_t address = 0x0000;
	setAddress(address);
	while (address != 0xffff) {
		setData(0x00);
		address++;
	}

	lcd.clear();
	displayMsg(ERASE);
	displayMsg(COMPLETE);
	delay(2000);
}

void printRegisters() {
	lcd.clear();
	for (uint8_t i=0; i < 5; i++) {
		lcd.setCursor(2*i, 1);
		if (i==0)
		  lcd.print(reg[0], HEX); // $ff40 spi read
		else
		  lcd.print(reg[i*2+14], HEX); // $ff48 spi read, $ff49 spi read, etc.
	}
	delay(2000);
	while (lcd.readButtons());
}

void viewROM() {
	lcd.clear();
	lcd.print("0000");
	
	uint16_t address = 0x0000;
	while (true) {
		if (address < 0x10)
		lcd.setCursor(3,0);
		else if (address < 0x100)
		lcd.setCursor(2,0);
		else if (address < 0x1000)
		lcd.setCursor(1,0);
		else
		lcd.setCursor(0,0);
		lcd.print(address, HEX);
		lcd.print(":");
		
		lcd.setCursor(0,1);
		lcd.print("0000000000000000");
		setAddress(address);
		for (int i=0; i < 8; i++) {
			lcd.setCursor(i*2,1);
			lcd.print(readData(), HEX);
		}
		
		while (1) {
			uint8_t buttons = lcd.readButtons();

			if (buttons) {
				if (buttons & BUTTON_SELECT)
					return;
				if (buttons & BUTTON_UP)
					address += 0x1000;
				if (buttons & BUTTON_RIGHT)
					address += 8;
				if (buttons & BUTTON_LEFT)
					address -= 8;
				if (buttons & BUTTON_DOWN)
					address -= 0x1000;
				break;
			}
		}
	}
	
	lcd.clear();
}

void createImage(char *name) {
  File image;
  
  if (SD.exists(name))
    return;

  image = SD.open(name, FILE_WRITE);
  for (uint32_t i=0; i < MAXTRACK*TRACKSIZE; i++)
    image.write(0xff);
  image.close();
}

// Wait until the DRO bit changes to 0
void waitDR() {
	while (reg[RW(FDCSTAT)] & 0x02)
		loadRegisters();
}

// Given a logical sector and track, find and return the
// file position of the start of the physical sector.
uint32_t findSector(File file, uint8_t track, uint8_t sector) {
	uint32_t pos;
	
	for (uint8_t i=1; i < 19; i++) {
		pos = track*TRACKSIZE+32+(i-1)*SECTORSIZE;
		file.seek(pos+12);
		if (file.read() != track)
			return 0;
		if (file.read() != 0x00)
			return 0;
		if (file.read() == sector)
			return pos;
	}
	return 0;
}

// Start to handle FDC instructions
void misc() {
	File image;
	uint8_t command = 0;
	uint8_t drive = 0;
	uint8_t ddir = 0;
	uint8_t control = 0;
	uint8_t sector = 1;
	uint8_t track = 0;
	uint32_t tmp;
	uint16_t crc;
	
	// Set reset register values for FDC
	setRegister(RW(DSKREG), 0x00); 
	setRegister(RW(FDCCMD), 0x04); 
	setRegister(RR(FDCTRK), 0x00); // track 0
	setRegister(RW(FDCTRK), 0x00);
	setRegister(RR(FDCSEC), 0x01); // sector 1
	setRegister(RW(FDCSEC), 0x01);
	createImage("floppy0.dsk");
	createImage("floppy1.dsk");
	createImage("floppy2.dsk");
	createImage("floppy3.dsk");

	image = SD.open("floppy0.dsk", FILE_WRITE);
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
					Serial.println("Opened disk 0");
					track = 0;
					sector = 1;
				}
				if ((control & 0x02) && (drive != 1)) {
					drive = 1;
					image.close();
					image = SD.open("floppy1.dsk", FILE_WRITE);
					Serial.println("Opened disk 1");
				}
				if ((control & 0x04) && (drive != 2)) {
					drive = 2;
					image.close();
					image = SD.open("floppy2.dsk", FILE_WRITE);
					Serial.println("Opened disk 2");
				}
				if ((control & 0x40) && (drive != 3)) {
					drive = 3;
					image.close();
					image = SD.open("floppy3.dsk", FILE_WRITE);
					Serial.println("Opened disk 3");
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
					image.seek(track*TRACKSIZE);
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
					tmp = findSector(image, track, sector);
					Serial.print("pos = ");
					Serial.println(tmp);
					image.seek(tmp+32+56);
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
					image.seek(findSector(image, track, sector)+32+56);
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
					image.seek(track*TRACKSIZE);
					setNMI(true);
					break;
				case 0xf4: // WRITE TRACK
					setRegister(RW(FDCSTAT), RW(FDCSTAT) | 0x01); // BUSY
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
					
					setRegister(RW(FDCSTAT), 0x00);
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

void programROM(File dataFile) {
	uint16_t address;
	
	lcd.clear();

	if (!dataFile) {
		displayMsg(OPEN_FAILED);
		return;
	}
	
	if (dataFile.size() <= 16*1024)
	address = 0xc000;
	else
	address = 0x8000;	
	setAddress(address);
	
	while (dataFile.available()) {
		uint8_t d = dataFile.read();
		
		if (address % 0x100 == 0) {
			lcd.setCursor(0,0);
			lcd.print("Prog: 0x");
			lcd.print(address, HEX);
			lcd.print(": ");
			lcd.print(d, HEX);
		}
		setData(d);
		address++;
	}

	dataFile.close();
	
	lcd.clear();
	displayMsg(PROGRAMMING);
	displayMsg(COMPLETE);
	delay(2000);
}
