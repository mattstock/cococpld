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

// Start to handle FDC instructions
void misc() {
	File image;
	uint16_t byte_cnt = 0;
	uint8_t read_cnt = 0;
	uint8_t command = 0;
	uint8_t drive = 0;
	uint8_t ddir = 0;
	uint8_t control = 0;
	uint8_t sector = 1;
	uint8_t track = 0;
	
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
			readRegisters();
			
			if (control != reg[RR(DSKREG)]) {
				Serial.println("Control register update");
				if (command != reg[RR(FDCCMD)]) {
					Serial.print("Crap, we have a potential issue: ");
					Serial.println(reg[RR(FDCCMD)]);
				}
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
					byte_cnt = 0;
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
				continue;
			}
			
			Serial.println("Command update");
			command = reg[RR(FDCCMD)];
			switch (reg[RR(FDCCMD)]) {
				case 0x03: // RESTORE
					Serial.println("RESTORE");
					setRegister(RW(FDCSTAT), 0x04);
					setRegister(RR(FDCTRK), 0x00); // track 0
					setRegister(RW(FDCTRK), 0x00);
					setRegister(RR(FDCSEC), 0x01); // sector 1
					setRegister(RW(FDCSEC), 0x01);
					image.seek(0);
					track = 0;
					sector = 1;
					read_cnt = 0;
					byte_cnt = 0;
					setNMI(true);
					break;
				case 0x17: // SEEK
					setRegister(RW(FDCSTAT), (track ? 0x01 : 0x05)); // BUSY;
					Serial.print("SEEK ");
					track = reg[RR(FDCDAT)];
					Serial.println(track, HEX);
					setRegister(RW(FDCTRK), track);
					setRegister(RW(FDCSEC), reg[RR(FDCSEC)]);
					image.seek(track*TRACKSIZE);
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
					byte_cnt = 0;
					Serial.println(track, HEX);
					if (track == 255)
						track = 0;						
					setRegister(RW(FDCSTAT), (track ? 0x24 : 0x20));
					setRegister(RW(FDCTRK), track);
					image.seek(track*TRACKSIZE);
					delay(15);
					setNMI(true);
					break;
				case 0x43: // STEP IN
					setRegister(RW(FDCSTAT), 0x21); // BUSY
					Serial.print("STEP IN ");
					track--;
					byte_cnt = 0;
					ddir = 0;
					if (track == 255)
						track = 0;
					setRegister(RW(FDCSTAT), (track ? 0x24 : 0x20));
					Serial.println(track);
					setRegister(RW(FDCTRK), track);
					image.seek(track*TRACKSIZE);
					delay(15);
					setNMI(true);
					break;
				case 0x53: // STEP OUT
					setRegister(RW(FDCSTAT), 0x21); // BUSY
					Serial.print("STEP OUT ");
				    track++;
					ddir = 1;
					Serial.println(track);
					byte_cnt = 0;
					setRegister(RW(FDCSTAT), 0x20);
					setRegister(RW(FDCTRK), track);
					image.seek(track*TRACKSIZE);
					delay(15);
					setNMI(true);
					break;
				case 0x80: // READ SECTOR
					setRegister(RW(FDCSTAT), 0x01); // BUSY
					track = reg[RR(FDCTRK)];
					sector = reg[RR(FDCSEC)];
					setRegister(RW(FDCSEC), sector);
					setRegister(RW(FDCTRK), track);
					image.seek(track*TRACKSIZE+(sector-1)*SECTORSIZE+32+8+3+1+1+1+1+1+1+22+12+3+1);
					Serial.print("READ SECTOR ");
					Serial.println(sector, HEX);
					
					for (int i = 0; i < 256; i++) {
						Serial.print(">");
						setRegister(RW(FDCDAT), image.read());
						setRegister(RW(FDCSTAT), 0x03);
						setHALT(false);
						delay(50);
					}
					
					Serial.println("");
					setRegister(RW(FDCSTAT), 0x00);
					setNMI(true);			
					break;
				case 0xa0: // WRITE SECTOR
					setRegister(RW(FDCSTAT), 0x01); // BUSY
					if (read_cnt == 0) {
						sector = reg[RR(FDCSEC)];
						setRegister(RW(FDCSEC), sector);
						image.seek(track*TRACKSIZE+(sector-1)*SECTORSIZE+32+8+3+1+1+1+1+1+1+22+12+3+1);
						Serial.print("WRITE SECTOR ");
						Serial.println(sector, HEX);
					}
					read_cnt++;
					image.write(reg[RR(FDCDAT)]);
					if (read_cnt) {
						setRegister(RW(FDCSTAT), 0x03);
						setHALT(false);
					} else {
						setRegister(RW(FDCSTAT), 0x00);
						setNMI(true);
					}
					break;
					Serial.println("WRITE SECTOR");
					sector = reg[RR(FDCSEC)];
					break;
				case 0xc0: // READ ADDRESS
					setRegister(RW(FDCSTAT), 0x01); // BUSY
					Serial.print("READ ADDRESS ");
					Serial.print(track);
					Serial.print("/");
					Serial.println(sector);

					setRegister(RW(FDCSTAT), 0x03); // BUSY, DRO
					switch (read_cnt) {
						case 0:
							setRegister(RW(FDCDAT), track);
							setHALT(false);
							read_cnt++;
							break;
						case 1:
							setRegister(RW(FDCDAT), 0x00);
							setHALT(false);
							read_cnt++;
							break;
						case 2:
							setRegister(RW(FDCDAT), sector);
							setHALT(false);
							read_cnt++;
							break;
						case 3:
							setRegister(RW(FDCDAT), 0x01);
							setHALT(false);
							read_cnt++;
							break;
						case 4:
							setRegister(RW(FDCDAT), 0x00); // CRC1
							setHALT(false);
							read_cnt++;
							break;
						case 5:
							setRegister(RW(FDCDAT), 0x00); // CRC2
							read_cnt = 0;
							setRegister(RW(FDCSTAT), 0x00); // clear BUSY
							setNMI(true);
							break;
					}
					break;
				case 0xe4: // READ TRACK
					Serial.println("READ TRACK");
					break;
				case 0xf4: // WRITE TRACK
					setRegister(RW(FDCSTAT), RW(FDCSTAT) | 0x01); // BUSY
					if (byte_cnt == 0)
						Serial.println("WRITE TRACK");
					image.write(reg[RR(FDCDAT)]);
					byte_cnt++;
					if (byte_cnt == TRACKSIZE) {
						setRegister(RW(FDCSTAT), 0x00); // Next track please
						setNMI(true); // command complete
					} else {
						setRegister(RW(FDCSTAT), 0x03);
						setHALT(false); // indicate that we processed this byte
					}
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
