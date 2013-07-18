#include "rom.h"
#include "busio.h"
#include "fdc.h"
#include "firmware2.h"
#include "DMKDisk.h"

uint32_t findRBFSector(File file, uint8_t side, uint32_t tracklen, uint16_t track, uint8_t sector) {
  return (side+1)*(track*tracklen+(sector-1)*256);
}

void printPair(uint16_t r) {
	Serial.print(reg[RR(r)], HEX);
	Serial.print("/");
	Serial.print(reg[RW(r)], HEX);
	Serial.print(" ");
}

void printRegs() {
	Serial.print("cmd/stat: ");
	printPair(FDCCMD);
	Serial.print("dskreg: ");
	printPair(DSKREG);
	Serial.print("fdcdat: ");
	printPair(FDCDAT);
	Serial.print("fdctrk: ");
	printPair(FDCTRK);
	Serial.print("fdcsec: ");
	printPair(FDCSEC);
	Serial.println("");
}

// Start to handle FDC instructions
void fdc() {
	uint8_t command = 0;
	uint8_t drive = 100;
	uint8_t control = 0;
	CocoDisk *disk = new CocoDisk(config[FLOPPY0], config[FLOPPY1]);
	
	Serial.println(config[DSKROM]);

	if (programROM(SD.open(config[DSKROM])) != 0)
		return;
	
	Serial.println("Programmed the disk rom");
	
	// Set reset register values for FDC
	setRegister(RW(DSKREG), 0x00);
	setRegister(RW(FDCSTAT), 0x04);
	setRegister(RR(FDCTRK), 0x00); // track 0
	setRegister(RW(FDCTRK), 0x00);
	setRegister(RR(FDCSEC), 0x01); // sector 1
	setRegister(RW(FDCSEC), 0x01);

	while (1) {
		if (digitalRead(CFGINT_PIN)) {
			loadConfigReg();
			control = reg[RR(DSKREG)];
			if (((control & 0x01) == 0x01) && (drive != 0)) {
				drive = 0;
				disk->setDrive(0);
			}
			if (((control & 0x02) == 0x02) && (drive != 1)) {
				drive = 1;
				disk->setDrive(1);
			}
			if (((control & 0x04) == 0x04) && (drive != 2)) {
				drive = 2;
				disk->setDrive(2);
			}
		}
		
		if (digitalRead(CMDINT_PIN)) {
			Serial.print("B: ");
			loadRegisters();
			printRegs();
			command = reg[RR(FDCCMD)];
			if ((command & 0xf0) == 0)
				disk->restore();
			if ((command & 0xf0) == 0x10)
				disk->seek(reg[RR(FDCDAT)]);
			if ((command & 0xe0) == 0x20)
				disk->step();
			if ((command & 0xe0) == 0x40)
				disk->stepin();
			if ((command & 0xe0) == 0x60)
				disk->stepout();
			if ((command & 0xf1) == 0x80)
				disk->readSector((control & 0x40) == 0x40, reg[RR(FDCSEC)]);
			if ((command & 0xf0) == 0xa0)
				disk->writeSector((control & 0x40) == 0x40, reg[RR(FDCSEC)]);
			if ((command & 0xfb) == 0xc0)
				disk->readAddress();
			if ((command & 0xfb) == 0xe0)
				disk->readTrack();
			if ((command & 0xfb) == 0xf0)
				disk->writeTrack();
			if ((command & 0xf8) == 0xd0)
				disk->forceInt();
		}
	}
	Serial.println("Exiting fdc()");
	delay(2000);
}
