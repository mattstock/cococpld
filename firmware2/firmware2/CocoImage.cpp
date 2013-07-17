/*
 * CocoImage.cpp
 *
 * Created: 7/16/2013 7:40:32 PM
 *  Author: stock
 */ 

#include "CocoImage.h"

uint16_t CocoImage::getSectorSize() {
	return sector_size;
}

uint32_t CocoImage::findSector(uint8_t side, uint8_t track, uint8_t sector) {
	if (sector > sectors_per_track || side >= max_sides)
		return 0;
	return 1L*track*(max_sides*sectors_per_track*sector_size) + 1L*side*(sectors_per_track*sector_size) + (sector-1)*sector_size;
}

RBFImage::RBFImage(char *name) {
	image = SD.open(name, FILE_WRITE);
	if (!image) {
		Serial.println("Failed to open Disk");
		return;
	}
			
	image.seek(3);
	sectors_per_track = image.read();
	sector_size = 256;
			
	image.seek(16);
	max_sides = (image.read() & 0x01) + 1;
}

RBFImage::~RBFImage() {
	image.close();
}

char *RBFImage::getSector(uint8_t side, uint16_t track, uint16_t sector) {
	char *tmp = (char *)malloc(sector_size);

	image.seek(findSector(side, track, sector));
	image.readBytes(tmp, sector_size);
};

boolean RBFImage::putSector(uint8_t side, uint16_t track, uint16_t sector, char *data) {
	image.seek(findSector(side, track, sector));
	image.write((uint8_t *)data, sector_size);
	return true;
}

DECBImage::DECBImage(char *name) {
	image = SD.open(name, FILE_WRITE);
	if (!image) {
		Serial.println("Failed to open Disk");
		return;
	}
	sectors_per_track = 18;
	sector_size = 256;
	if (image.size() == sectors_per_track*sector_size*35L)
		max_sides = 1;
	else
		max_sides = 2;
	Serial.print("sides = ");
	Serial.println(max_sides, HEX);
}

DECBImage::~DECBImage() {
	image.close();
}

char *DECBImage::getSector(uint8_t side, uint16_t track, uint16_t sector) {
	char *tmp = (char *)malloc(sector_size);
	uint32_t pos = findSector(side, track, sector);
	Serial.print("pos = ");
	Serial.println(pos, HEX);
	image.seek(pos);
	if (image.readBytes(tmp, sector_size) != sector_size) {
		Serial.println("Failed to read from image");
		return NULL;
	}
	return tmp;
};

boolean DECBImage::putSector(uint8_t side, uint16_t track, uint16_t sector, char *data) {
	image.seek(findSector(side, track, sector));
	image.write((uint8_t *)data, sector_size);
	return true;
}

