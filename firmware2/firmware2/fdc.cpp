#include "rom.h"
#include "busio.h"
#include "fdc.h"
#include "firmware2.h"
#include "DMKDisk.h"

uint32_t findRBFSector(File file, uint8_t side, uint32_t tracklen, uint16_t track, uint8_t sector) {
  return (side+1)*(track*tracklen+(sector-1)*256);
}

// Start to handle FDC instructions
void fdc() {
	uint8_t command = 0;
	uint8_t drive = 100;
	uint8_t control = 0;	
	RBFDisk disk;
	
	Serial.println(config[DSKROM]);

	if (programROM(SD.open(config[DSKROM])) != 0)
		return;
	
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
				control = reg[RR(DSKREG)];
				if ((control & 0x47) & ((control & 0x47)-1)) {
					Serial.print("skipping crap: ");
					Serial.println(control);
					continue;
				}
				if (!(control & 0x47)) {
#ifdef DEBUG
					Serial.println("Closing open floppy");
#endif
					drive = 100;
				}
				if ((control & 0x09) && (drive != 0)) {
					drive = 0;
					Serial.println("Firing up drive 0");
					disk.setup(config[FLOPPY0]);		
				}
				if ((control & 0x0a) && (drive != 1)) {
					drive = 1;
					Serial.println("Firing up drive 1");
					disk.setup(config[FLOPPY1]);
				}
			}
			
			if (command == reg[RR(FDCCMD)] || drive == 100)
				continue;
			
			command = reg[RR(FDCCMD)];
			Serial.print("Command: ");
			Serial.println(command, HEX);
			if ((command & 0xf0) == 0)
				disk.restore();
			if ((command & 0xf0) == 0x10)
				disk.seek(reg[RR(FDCDAT)]);
			if ((command & 0xe0) == 0x20)
				disk.step();
			if ((command & 0xe0) == 0x40)
				disk.stepin();
			if ((command & 0xe0) == 0x60)
				disk.stepout();
			if ((command & 0xf1) == 0x80)
				disk.readSector((command & 0x08) == 0x08, reg[RR(FDCSEC)]);
			if ((command & 0xf0) == 0xa0)
				disk.writeSector((command & 0x08) == 0x08, reg[RR(FDCSEC)]);
			if ((command & 0xfb) == 0xc0)
				disk.readAddress();
			if ((command & 0xfb) == 0xe0)
				disk.readTrack();
			if ((command & 0xfb) == 0xf0)
				disk.writeTrack();
			if ((command & 0xf8) == 0xd0)
				disk.forceInt();

		}
	}
	delay(2000);
}
