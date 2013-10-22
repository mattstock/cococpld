#include "rom.h"
#include "busio.h"
#include "fdc.h"
#include "firmware2.h"
#include "CocoDisk.h"
#include <util/atomic.h>

uint32_t findRBFSector(File file, uint8_t side, uint32_t tracklen, 
		       uint16_t track, uint8_t sector) {
  return (side+1)*(track*tracklen+(sector-1)*256);
}

// Start to handle FDC instructions
void fdc() {
  uint8_t drive = 100;
  CocoDisk disk(config[FLOPPY0], config[FLOPPY1]);
  
  Serial.print("Ram: ");
  Serial.println(FreeRam());
  
  if (programROM(SD.open(config[DSKROM])) != 0) {
    Serial.println("ROM programming failure!");
    return;
  }
  if (verifyROM(SD.open(config[DSKROM])) != 0) {
    Serial.println("ROM verify failure!");
    return;
  }
    
  Serial.print("Ram: ");
  Serial.println(FreeRam());
  
  Serial.println("Programmed the disk rom");
  
  // Set reset register values for FDC
  setRegister(DSKREG, 0x00);
  setRegister(FDCSTAT, 0x04);
  setRegister(FDCTRK, 0x00); // track 0
  setRegister(FDCSEC, 0x01); // sector 1
  
  wakeCoco();
  
  while (1) {
    if (controlPending) {
      controlPending = false;
      Serial.print("ControlInt: ");
      Serial.println(dskreg, HEX);
      if (((dskreg & 0x01) == 0x01) && (drive != 0)) {
	drive = 0;
	disk.setDrive(0);
      }
      if (((dskreg & 0x02) == 0x02) && (drive != 1)) {
	drive = 1;
	disk.setDrive(1);
      }
      if (((dskreg & 0x04) == 0x04) && (drive != 2)) {
	drive = 2;
	disk.setDrive(2);
      }
    }
    
    if (commandPending) {
      commandPending = false;
      loadFDCRegisters();
      loadStatus();
      if ((fdccmd & 0xf0) == 0)
	disk.restore();
      if ((fdccmd & 0xf0) == 0x10)
	disk.seek(fdcdat);
      if ((fdccmd & 0xe0) == 0x20)
	disk.step();
      if ((fdccmd & 0xe0) == 0x40)
	disk.stepin();
      if ((fdccmd & 0xe0) == 0x60)
	disk.stepout();
      if ((fdccmd & 0xf1) == 0x80)
	disk.readSector((dskreg & 0x40) == 0x40, fdcsec);
      if ((fdccmd & 0xf0) == 0xa0) {
	if (disk.writeSector((dskreg & 0x40) == 0x40, fdcsec)) {
	  loadSetup();
	  disk.setup(config[FLOPPY0], config[FLOPPY1]);
	}
      }
      if ((fdccmd & 0xfb) == 0xc0)
	disk.readAddress();
      if ((fdccmd & 0xfb) == 0xe0)
	disk.readTrack();
      if ((fdccmd & 0xfb) == 0xf0)
	disk.writeTrack();
      if ((fdccmd & 0xf8) == 0xd0)
	disk.forceInt();
    }
  }
  Serial.println("Exiting fdc()");
  delay(2000);
}
