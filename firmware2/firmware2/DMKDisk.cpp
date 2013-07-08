#include "DMKDisk.h"
#include "fdc.h"
#include "busio.h"


CocoDisk::CocoDisk() {
}

CocoDisk::~CocoDisk() {
	
}

int DMKDisk::setup(char *name) {
	image = SD.open(name, FILE_WRITE);
	if (!image) {
		Serial.println("Failed to open CocoDisk");
		return -1;
	}
	track = 0;
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

int RBFDisk::setup(char *name)  {
	image = SD.open(name, FILE_WRITE);
	if (!image) {
		Serial.println("Failed to open CocoDisk");
		return -1;
	}
	
	image.seek(0);
	
	max_sectors = image.read();
	max_sectors = (max_sectors << 8) + image.read();
	max_sectors = (max_sectors << 8) + image.read();
	
	Serial.print("max sectors = ");
	Serial.println(max_sectors, HEX);
	
	tracklen = image.read() * 256L;

	Serial.print("track length (bytes) = ");
	Serial.println(tracklen, HEX);
	
	image.seek(16);	
	max_sides = (image.read() & 0x01) + 1;
	
	Serial.print("sides = ");
	Serial.println(max_sides, HEX);
	track = 0;
	return 0;
}

RBFDisk::~RBFDisk() {
	image.close();
}

// Given a logical sector find and return the
// file position of the start of the physical sector on the current track.
uint32_t RBFDisk::findSector(uint8_t side, uint8_t sector) {
	uint32_t pos;
	
	if (sector > max_sectors || side >= max_sides)
	return 0;
	
	pos = max_sides*tracklen*track;
	
	#ifdef DEBUG
	Serial.print("findSector(");
	Serial.print(track, HEX);
	Serial.print(",");
	Serial.print(sector, HEX);
	Serial.print(") = ");
	Serial.println(pos, HEX);
	#endif
	
	return pos + (sector-1)*max_sides*256L+side*256L;
}

void CocoDisk::restore() {
#ifdef DEBUG
	Serial.println("RESTORE");
#endif
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
#ifdef DEBUG
	Serial.print("SEEK ");
	Serial.println(track, HEX);
#endif
	setRegister(RW(FDCTRK), track);
	setRegister(RW(FDCSTAT), (track ? 0x04 : 0x00)); // Set track 0;
	setNMI(true);
}

void CocoDisk::step() {
	setRegister(RW(FDCSTAT), (track ? 0x21 : 0x25)); // BUSY;
	if (ddir)
		track++;
	else
		track--;
#ifdef DEBUG
	Serial.print("STEP ");
	Serial.println(track, HEX);
#endif
	setRegister(RW(FDCSTAT), (track ? 0x24 : 0x20));
	setNMI(true);
}

void CocoDisk::stepin() {
	setRegister(RW(FDCSTAT), 0x21); // BUSY
#ifdef DEBUG
	Serial.print("STEP IN ");
#endif
	track--;
	ddir = false;
	if (track < 0)
		track = 0;
	setRegister(RW(FDCSTAT), (track ? 0x24 : 0x20));
}

void CocoDisk::stepout() {
	setRegister(RW(FDCSTAT), 0x21); // BUSY
#ifdef DEBUG
	Serial.print("STEP OUT ");
#endif
	track++;
	ddir = true;
	setRegister(RW(FDCSTAT), 0x20);
	setNMI(true);
}

void CocoDisk::readSector(uint8_t side, uint8_t sector) {
	uint32_t tmp;
		
	setRegister(RW(FDCSTAT), 0x01); // BUSY
	
	tmp = findSector(side, sector);
	image.seek(tmp);

#ifdef DEBUG
	Serial.print("read sector offset for (");
	Serial.print(side, HEX);
	Serial.print(",");
	Serial.print(track, HEX);
	Serial.print(",");
	Serial.print(sector, HEX);
	Serial.print(") = ");
	Serial.println(tmp, HEX);
#endif

	// The first byte uses a simple busy wait on the Coco side
	// making this loop somewhat complicated on the head and tail.
	for (int i = 0; i < 256; i++) {
		setRegister(RW(FDCDAT), image.read());
		setRegister(RW(FDCSTAT), 0x03);
		if (i != 0)
			setHALT(false);
		if (i != 255)
			waitDR();
	}	
	setRegister(RW(FDCSTAT), 0x00);
	setNMI(true);	
}

void CocoDisk::writeSector(uint8_t side, uint8_t sector) {
	uint32_t tmp;

	setRegister(RW(FDCSTAT), 0x01); // BUSY
	tmp = findSector(side, sector);
	image.seek(tmp);
#ifdef DEBUG
	Serial.print("write sector offset for (");
	Serial.print(side, HEX);
	Serial.print(",");
	Serial.print(track, HEX);
	Serial.print(",");
	Serial.print(sector, HEX);
	Serial.print(") = ");
	Serial.println(tmp, HEX);
#endif
	for (int i=0; i < 256; i++) {
		setRegister(RW(FDCSTAT), 0x03);
		if (i != 0)
			setHALT(false);
		waitDR();
		image.write(reg[RR(FDCDAT)]);
	}			
	setRegister(RW(FDCSTAT), 0x00);
	setNMI(true);	
}

void CocoDisk::readAddress() {
	setRegister(RW(FDCSTAT), 0x01); // BUSY
#ifdef DEBUG
	Serial.print("READ ADDRESS ");
#endif
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
	setNMI(true);
}

// Wait until the DRO bit changes to 0
void CocoDisk::waitDR() {
	while (reg[RW(FDCSTAT)] & 0x02)
	loadRegisters();
}
