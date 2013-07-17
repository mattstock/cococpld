#ifndef COCODISK_H
#define COCODISK_H

#include "CocoImage.h"

class CocoDisk {

	public:

	CocoDisk(CocoImage *image);
	~CocoDisk();
	void restore();
	void seek(uint16_t track);
	void step();
	void stepin();
	void stepout();
	void readSector(uint8_t side, uint8_t sector);
	void writeSector(uint8_t side, uint8_t sector);
	void readAddress();
	void readTrack();
	void writeTrack();
	void forceInt();

	protected:

	void waitDR();

	CocoImage *disk;
	uint32_t track;
	boolean ddir;

};

#endif