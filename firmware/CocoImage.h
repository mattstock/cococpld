#ifndef COCOIMAGE_H
#define COCOIMAGE_H

#include <SD.h>

class CocoImage {

	public:
	
	CocoImage() = default;
	CocoImage(char *name);
	virtual ~CocoImage();
	virtual char *getSector(uint8_t side, uint16_t track, uint16_t sector);
	virtual boolean putSector(uint8_t side, uint16_t track, uint16_t sector, char *data);
	uint16_t getSectorSize();
	uint32_t findSector(uint8_t side, uint8_t track, uint8_t sector);	
	
	protected:
	
	uint16_t sector_size;
	uint8_t max_sides;
	uint32_t sectors_per_track;
	File image;
};

class VirtualImage : public CocoImage {

	public:
	
	VirtualImage();
	char *getSector(uint8_t side, uint16_t track, uint16_t sector);
	boolean putSector(uint8_t side, uint16_t track, uint16_t sector, char *data);
};
#endif