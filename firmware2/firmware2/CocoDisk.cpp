#include "CocoDisk.h"
#include "fdc.h"
#include "busio.h"

CocoDisk::CocoDisk(CocoImage *image) {
	disk = image;
}

CocoDisk::~CocoDisk() {
	delete disk;
}

void CocoDisk::restore() {
	Serial.println("RESTORE");
	setRegister(RW(FDCSTAT), 0x04);
	setRegister(RR(FDCTRK), 0x00); // track 0
	setRegister(RW(FDCTRK), 0x00);
	setRegister(RR(FDCSEC), 0x01); // sector 1
	setRegister(RW(FDCSEC), 0x01);
	track = 0;
	ddir = true;
	setNMI(true);
}

void CocoDisk::seek(uint16_t track) {
	setRegister(RW(FDCSTAT), (track ? 0x01 : 0x05)); // BUSY;
	this->track = track;
	Serial.print("SEEK ");
	Serial.println(track, HEX);
	setRegister(RW(FDCTRK), track);
	setRegister(RW(FDCSTAT), (track ? 0x00 : 0x04)); // Set track 0;
	setNMI(true);
}

void CocoDisk::step() {
	setRegister(RW(FDCSTAT), (track ? 0x21 : 0x25)); // BUSY;
	if (ddir)
		track++;
	else
		track--;
	Serial.print("STEP ");
	Serial.println(track, HEX);
	setRegister(RW(FDCTRK), track);
	setRegister(RW(FDCSTAT), (track ? 0x20 : 0x24));
	setNMI(true);
}

void CocoDisk::stepin() {
	setRegister(RW(FDCSTAT), 0x21); // BUSY
	Serial.print("STEP IN ");
	track--;
	ddir = false;
	if (track < 0)
		track = 0;
	setRegister(RW(FDCTRK), track);
	setRegister(RW(FDCSTAT), (track ? 0x20 : 0x24));
}

void CocoDisk::stepout() {
	setRegister(RW(FDCSTAT), 0x21); // BUSY
	Serial.print("STEP OUT ");
	track++;
	ddir = true;
	setRegister(RW(FDCTRK), track);
	setRegister(RW(FDCSTAT), 0x20);
	setNMI(true);
}

void CocoDisk::readSector(uint8_t side, uint8_t sector) {
	uint16_t sector_size = disk->getSectorSize();
	char *sector_data;
	
	setRegister(RW(FDCSTAT), 0x01); // BUSY
	
	sector_data = disk->getSector(side, track, sector);

	// The first byte uses a simple busy wait on the Coco side
	// making this loop somewhat complicated on the head and tail.
	delayMicroseconds(50);
	for (uint16_t i = 0; i < sector_size; i++) {
		setRegister(RW(FDCDAT), sector_data[i]);
		setRegister(RW(FDCSTAT), 0x02);
		if (i != 0)
			setHALT(false);
		if (i != sector_size-1)
			waitDR();
	}
	setRegister(RW(FDCSEC), sector);
	setRegister(RW(FDCSTAT), 0x00);
	Serial.println("");
	setNMI(true);
	free(sector_data);
}

void CocoDisk::writeSector(uint8_t side, uint8_t sector) {
	uint16_t sector_size = disk->getSectorSize();
	char *sector_data = (char *)malloc(sector_size);

	setRegister(RW(FDCSTAT), 0x01); // BUSY
	for (uint16_t i=0; i < sector_size; i++) {
		setRegister(RW(FDCSTAT), 0x03);
		if (i != 0)
			setHALT(false);
		waitDR();
		loadRegisters();
		sector_data[i] = reg[RR(FDCDAT)];
	}
	setRegister(RW(FDCSEC), sector);
	setRegister(RW(FDCSTAT), 0x00);
	setNMI(true);
	disk->putSector(side, track, sector, sector_data);
	free(sector_data);
}

void CocoDisk::readAddress() {
	setRegister(RW(FDCSTAT), 0x01); // BUSY
	Serial.print("READ ADDRESS ");
	setRegister(RW(FDCSTAT), 0x03); // BUSY, DRO
	setRegister(RW(FDCDAT), track);
	setHALT(false);
	setRegister(RW(FDCDAT), 0x00);
	setHALT(false);
	setRegister(RW(FDCDAT), 0x01); // Random sector
	setHALT(false);
	setRegister(RW(FDCDAT), 0x01);
	setHALT(false);
	setRegister(RW(FDCDAT), 0x00); // CRC1
	setHALT(false);
	setRegister(RW(FDCDAT), 0x00); // CRC2
	setRegister(RW(FDCSTAT), 0x00); // clear BUSY
	setNMI(true);
}

void CocoDisk::readTrack() {
	setRegister(RW(FDCSTAT), 0x80); // throw error
	setNMI(true);
}

void CocoDisk::writeTrack() {
	setRegister(RW(FDCSTAT), 0x80); // throw error
	setNMI(true);
}

void CocoDisk::forceInt() {
	Serial.println("FORCE INT");
	setRegister(RW(FDCSTAT), (track ? 0x00 : 0x04));
}

// Wait until the DRO bit changes to 0
void CocoDisk::waitDR() {
	int i=0;
	while (reg[RW(FDCSTAT)] & 0x02) {
		delayMicroseconds(1);
		i++;
		if (i == 30) {
			setHALT(false);
			i=0;
		}
		loadStatusReg();
	}

}

