#ifndef DMKDISK_H
#define DMKDISK_H

#include <SD.h>

class CocoDisk {

public:

	CocoDisk();
	virtual ~CocoDisk() = 0;
	virtual int setup(char *name) = 0;
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
	virtual uint32_t findSector(uint8_t side, uint8_t sector) = 0;

	File image;
	uint32_t tracklen;
	uint8_t trackcnt;
	uint32_t track;
	boolean ddir;		
	uint32_t max_sectors;
	uint8_t max_sides;
};

class DMKDisk : public CocoDisk {
	
public:
	~DMKDisk();
	int setup(char *name);
	
protected:
	
	uint32_t findSector(uint8_t side, uint8_t sector);
};

class RBFDisk : public CocoDisk {
	
public:
	~RBFDisk();
	int setup(char *name);
	
protected:
	uint32_t findSector(uint8_t side, uint8_t sector);	
};

class RAWDisk : public CocoDisk {

public:
	~RAWDisk();
	int setup(char *name);
	
protected:
	uint32_t findSector(uint8_t side, uint8_t sector);
};

class VirtualDisk : public CocoDisk {

public:
	~VirtualDisk();
	int setup(char *name);
	
protected:

	uint32_t findSector(uint8_t side, uint8_t sector);
};

#endif
