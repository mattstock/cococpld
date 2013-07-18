#ifndef COCOIMAGE_H
#define COCOIMAGE_H

#include <SD.h>

class CocoImage {

	public:
	
	virtual ~CocoImage();
	virtual char *getSector(uint8_t side, uint16_t track, uint16_t sector) = 0;
	virtual boolean putSector(uint8_t side, uint16_t track, uint16_t sector, char *data) = 0;
	uint16_t getSectorSize();
	uint32_t findSector(uint8_t side, uint8_t track, uint8_t sector);
	
	protected:
	
	uint16_t sector_size;
	uint8_t max_sides;
	uint32_t sectors_per_track;
};

class RBFImage : public CocoImage {

	public:
	
	RBFImage(char *name);
	~RBFImage();
	char *getSector(uint8_t side, uint16_t track, uint16_t sector);
	boolean putSector(uint8_t side, uint16_t track, uint16_t sector, char *data);
	
	private:
	
	File image;
};

class DECBImage : public CocoImage {

	public:
	
	DECBImage(char *name);
	~DECBImage();
	char *getSector(uint8_t side, uint16_t track, uint16_t sector);
	boolean putSector(uint8_t side, uint16_t track, uint16_t sector, char *data);
	
	private:
	
	File image;
};

class VirtualImage : public CocoImage {

	public:
	
	VirtualImage();
	~VirtualImage();
	char *getSector(uint8_t side, uint16_t track, uint16_t sector);
	boolean putSector(uint8_t side, uint16_t track, uint16_t sector, char *data);

	private:
	
	uint8_t image_count;
	File image;
};
#endif