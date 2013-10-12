﻿#include "CocoDisk.h"
#include "fdc.h"
#include "busio.h"

CocoDisk::CocoDisk() {
	disk = NULL;
}

CocoDisk::CocoDisk(const char *disk1, const char *disk2) {
	disk = NULL;
	active = 9;
	this->setup(disk1, disk2);
}

CocoDisk::~CocoDisk() {
	if (disk != NULL)
		delete disk;
	disk = NULL;
	active = 9;
}

void CocoDisk::setup(const char *disk1, const char *disk2) {
	if (disk != NULL)
		delete disk;
	disk = NULL;
	strncpy(diskname1, disk1, 13);
	strncpy(diskname2, disk2, 13);
}

void CocoDisk::setDrive(uint8_t d) {
	Serial.print("setting drive: ");
	Serial.println(d, HEX);
	if (d > 2)
		return;
	if (disk != NULL)
		delete disk;
	disk = NULL;
	active = d;	
}

void CocoDisk::restore() {
	Serial.println("RESTORE");
	setRegister(RR(FDCTRK), 0x00); // track 0
	setRegister(RW(FDCTRK), 0x00);
	setRegister(RR(FDCSEC), 0x01); // sector 1
	setRegister(RW(FDCSEC), 0x01);
	setRegister(RW(FDCSTAT), 0x04); // clear busy flag last
	track = 0;
	ddir = true;
	setNMI();
}

void CocoDisk::seek(uint16_t track) {
	this->track = track;
	Serial.print("SEEK ");
	Serial.println(track, HEX);
	setRegister(RW(FDCTRK), track);
	setRegister(RW(FDCSTAT), (track ? 0x00 : 0x04)); // Set track 0, clear busy
	setNMI();
}

void CocoDisk::step() {
	if (ddir)
		track++;
	else
		track--;
	Serial.print("STEP ");
	Serial.println(track, HEX);
	setRegister(RW(FDCTRK), track);
	setRegister(RW(FDCSTAT), (track ? 0x20 : 0x24));
	setNMI();
}

void CocoDisk::stepin() {
	Serial.print("STEP IN ");
	track--;
	ddir = false;
	if (track < 0)
		track = 0;
	setRegister(RW(FDCTRK), track);
	setRegister(RW(FDCSTAT), (track ? 0x20 : 0x24));
}

void CocoDisk::stepout() {
	Serial.print("STEP OUT ");
	track++;
	ddir = true;
	setRegister(RW(FDCTRK), track);
	setRegister(RW(FDCSTAT), 0x20);
	setNMI();
}

void CocoDisk::readSector(uint8_t side, uint8_t sector) {
	uint16_t sector_size;
	char *sector_data;
	
	Serial.print("Read sector: ");
	Serial.print(side);
	Serial.print(",");
	Serial.print(track, HEX);
	Serial.print(",");
	Serial.println(sector, HEX);
	
	if (disk == NULL)
		loadActiveImage();
	
	sector_size = disk->getSectorSize();
	sector_data = (char *)malloc(sector_size);
	sector_data = disk->getSector(side, track, sector);

	for (uint16_t i = 0; i < sector_size; i++) {
/*		if (sector_data[i] < 0x0f)
			Serial.print("0");
		Serial.print(sector_data[i], HEX);
		if (((i+1) % 16) == 0)
			Serial.println(""); */
		setRegister(RW(FDCDAT), sector_data[i]);
//		if (i != 0)
			clearHALT();
		if (i != sector_size-1)
			waitDR();
	}
	setRegister(RW(FDCSEC), sector);
	setRegister(RW(FDCSTAT), 0x00);
	Serial.println("Done with block write");
	setNMI();
	free(sector_data);
}

// Returns true if the config file needs reloading
boolean CocoDisk::writeSector(uint8_t side, uint8_t sector) {
	uint16_t sector_size;
	char *sector_data;
	boolean result;
	
	if (disk == NULL)
		loadActiveImage();
	
	sector_size = disk->getSectorSize();
	sector_data = (char *)malloc(sector_size);
	for (uint16_t i=0; i < sector_size; i++) {
		setRegister(RW(FDCSTAT), 0x03);
		if (i != 0)
			clearHALT();
		waitDR();
		loadFDCRegisters();
		sector_data[i] = reg[RR(FDCDAT)];
	}
	setRegister(RW(FDCSEC), sector);
	setRegister(RW(FDCSTAT), 0x00);
	setNMI();
	result = disk->putSector(side, track, sector, sector_data);
	free(sector_data);
	return result;	
}

void CocoDisk::readAddress() {
	Serial.print("READ ADDRESS ");
	setRegister(RW(FDCDAT), track);
	clearHALT();
	setRegister(RW(FDCDAT), 0x00);
	clearHALT();
	setRegister(RW(FDCDAT), 0x01); // Random sector
	clearHALT();
	setRegister(RW(FDCDAT), 0x01);
	clearHALT();
	setRegister(RW(FDCDAT), 0x00); // CRC1
	clearHALT();
	setRegister(RW(FDCDAT), 0x00); // CRC2
	setRegister(RW(FDCSTAT), 0x00); // clear BUSY
	setNMI();
}

void CocoDisk::readTrack() {
	setRegister(RW(FDCSTAT), 0x80); // throw error
	setNMI();
}

void CocoDisk::writeTrack() {
	setRegister(RW(FDCSTAT), 0x80); // throw error
	setNMI();
}

void CocoDisk::forceInt() {
	Serial.println("FORCE INT");
	setRegister(RW(FDCSTAT), (track ? 0x00 : 0x04));
//	setNMI(true);
}

// Wait until the DRO bit changes to 0
void CocoDisk::waitDR() {
	int i=0;
	loadStatus();
	while (reg[RW(FDCSTAT)] & 0x02) {
/*		Serial.print(">");
		i++;
		if (i == 30) {
			Serial.print("!");
			clearHALT();
			i=0;
		}*/
		loadStatus();
	}
}

void CocoDisk::loadActiveImage() {
	if (active == 0)
		disk = new CocoImage(diskname1);
	if (active == 1)
		disk = new CocoImage(diskname2);
	if (active == 2)
		disk = new VirtualImage();
	if (disk == NULL) {
		Serial.println("Disk memory allocation failed");
		while (1);
	}
}
