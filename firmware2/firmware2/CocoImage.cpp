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

CocoImage::CocoImage(char *name) {	
	image = SD.open(name, FILE_WRITE);
	if (!image) {
		Serial.println("Failed to open Disk");
		return;
	}

	sectors_per_track = 18;
	sector_size = 256;
			
	if (!strncasecmp("rbf", &(name[strlen(name)-3]), 3)) {
		image.seek(3);
		sectors_per_track = image.read();
		
		image.seek(16);
		max_sides = (image.read() & 0x01) + 1;
		Serial.println("RBF image");
	}
	
	if (!strncasecmp("dec", &(name[strlen(name)-3]), 3)) {
		if (image.size() == sectors_per_track*sector_size*35L)
			max_sides = 1;
		else
			max_sides = 2;
		Serial.println("DECB image");
	}
}

CocoImage::~CocoImage() {
	image.close();
}

char *CocoImage::getSector(uint8_t side, uint16_t track, uint16_t sector) {
	char *tmp = (char *)malloc(sector_size);
	uint32_t pos = findSector(side, track, sector);
	//	Serial.print("pos = ");
	//	Serial.println(pos, HEX);
	image.seek(pos);
	if (image.readBytes(tmp, sector_size) != sector_size) {
		Serial.println("Failed to read from image");
		return NULL;
	}
	return tmp;
};

boolean CocoImage::putSector(uint8_t side, uint16_t track, uint16_t sector, char *data) {
	image.seek(findSector(side, track, sector));
	image.write((uint8_t *)data, sector_size);
	return true;
}

VirtualImage::VirtualImage() {	
	// Initialize directory and FAT sector with relevant data from SD card
	// we cache this on disk because it takes up too much memory.  To avoid
	// cache issues we build it fresh each time we fire up the virtual image.
	// The disk image in this case is only a view of track 17 sectors 2-11.
	char *name;
	char filename[11];
	int idx;
	uint8_t image_count;
	
	sectors_per_track = 18;
	sector_size = 256;
	max_sides = 1;

	File root = SD.open("/");
	if (!root)
		return;
	
	image = SD.open("track17.dat", FILE_WRITE);
	image.seek(0);

	// Initialize
	for (uint16_t i=0; i < sector_size*10L; i++)
		if (i > 67 && i < 256)
			image.write((uint8_t)0x00); // FAT zeroing
		else
			image.write((uint8_t)0xff);
	
	root.rewindDirectory();
	image_count = 0;
	while (true) {
		File entry = root.openNextFile();
		if (!entry)
			break;
		if (!entry.isDirectory()) {
			image.seek(sector_size+image_count*32L);
			name = entry.name();
			Serial.print(name);
			Serial.print(": ");
			Serial.print(sector_size+image_count*32L, HEX);
			Serial.print(", ");
			Serial.println(image_count, HEX);
			idx = 0;
			for (int i=0; i < 11; i++)
				filename[i] = ' ';			
			for (uint8_t i=0; i < strlen(name); i++)
				if (name[i] != '.')
					filename[idx++] = name[i];
				else
				  idx = 8;
			image.write((uint8_t *)filename, 11);
			image.write((uint8_t)0x03);
			image.write((uint8_t)0xff);
			image.write(image_count); // Granule
			image.write((uint8_t)0x00); // Size
			image.write((uint8_t)0x01);
			// Fix the FAT entry as well
			image.seek(image_count);
			image.write(0xc1);
			image_count++;
		}
		entry.close();
	}
	image.close();
	root.close();
	image = SD.open("track17.dat"); // RO copy
}

char *VirtualImage::getSector(uint8_t side, uint16_t track, uint16_t sector) {
	char *sector_data = (char *)malloc(sector_size);
	
	Serial.print("track = ");
	Serial.println(track, HEX);
	
	// Unless it's the directory track, we ignore it for now
	if (track != 0x11) {
	  for (uint16_t i = 0; i < sector_size; i++)
	    sector_data[i] = 0x20;
	  return sector_data;
	}
	
	// We only keep sectors 2-11, so offset and pull from the disk file.
	image.seek(sector_size*(sector-2));
	image.readBytes(sector_data, sector_size);
	return sector_data;
}

// false if the config didn't change, true if it did?
boolean VirtualImage::putSector(uint8_t side, uint16_t track, uint16_t sector, char *data) {
	char name[13];
	
	// Setup data on track 0
	if (track != 0)
		return false;
	
	// Parse sector data
	// Sector 1 is the name of the first virtual disk image
	// Sector 2 is the name of the second virtual disk image
	
	if (sector == 1) {
		Serial.print("requesting new disk 1: ");
		memcpy(name, data, 12);
		name[12] = '\0';
		Serial.println(name);
	}
	if (sector == 2) {
		Serial.print("requesting new disk 2: ");
		memcpy(name, data, 12);
		name[12] = '\0';
		Serial.println(name);
	}
	return true;
}
