#ifndef DMKDISK_H
#define DMKDISK_H

#include "CocoDisk.h"

class DMKDisk {
	
public:
	~DMKDisk();
	int setup(char *name);
	
protected:
	
	uint32_t findSector(uint8_t side, uint8_t sector);
};

#endif
