#include "DMKDisk.h"


int DMKDisk::setup(char *name) {
	image = SD.open(name, FILE_WRITE);
	if (!image) {
		Serial.println("Failed to open DMKDisk");
		return -1;
	}
	max_sectors = 18;
	max_sides = 1;
	
	image.seek(1);
	trackcnt = image.read();
	tracklen = image.read();
	tracklen += (image.read() << 8);
	Serial.println(image.name());	
	Serial.print("trackcnt: ");
	Serial.print(trackcnt);
	Serial.print(" tracklen: ");
	Serial.println(tracklen);
	
	return 0;
}

DMKDisk::~DMKDisk() {
	image.close();
}

// Given a logical sector find and return the
// file position of the start of the physical sector on the current track.
uint32_t DMKDisk::findSector(uint8_t side, uint8_t sector) {
	uint32_t pos;
	uint32_t off;
	uint8_t cnt;

	if (sector > max_sectors || side >= max_sides)
	return 0;

	pos = 0x10 + tracklen*track;
#ifdef DEBUG
	Serial.print("findSector(");
	Serial.print(track, HEX);
	Serial.print(",");
	Serial.print(sector, HEX);
	Serial.print(") = ");
	Serial.println(pos, HEX);
#endif
	image.seek(pos);
	off = image.read();
	off += ((0x3f & image.read()) << 8);
	cnt = 0;
	
	while (off != 0) {
#ifdef DEBUG
		Serial.print("Checking: ");
		Serial.println(pos+off, HEX);
#endif
		image.seek(pos+off+3);
		if (image.read() == sector)
			return pos+off+0x2d;
		cnt++;
		image.seek(pos+2*cnt);
		off = image.read();
		off += ((0x3f & image.read()) << 8);
	}
	return 0;
}
