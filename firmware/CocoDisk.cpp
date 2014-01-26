#include "CocoDisk.h"
#include "fdc.h"
#include "busio.h"

CocoDisk::CocoDisk() {
  disk = NULL;
  sector_data = NULL;
}

CocoDisk::CocoDisk(const char *disk1, const char *disk2) {
  disk = NULL;
  sector_data = NULL;
  active = 9;
  this->setup(disk1, disk2);
}

CocoDisk::~CocoDisk() {
  if (disk != NULL)
    delete disk;
  if (sector_data != NULL)
    free(sector_data);
  sector_data = NULL;
  disk = NULL;
  active = 9;
}

void CocoDisk::setup(const char *disk1, const char *disk2) {
  if (disk != NULL)
    delete disk;
  disk = NULL;
  if (sector_data != NULL)
    free(sector_data);
  sector_data = NULL;
  strncpy(diskname1, disk1, 13);
  strncpy(diskname2, disk2, 13);
}

void CocoDisk::setDrive(uint8_t d) {
  Serial.print("New drive: ");
  Serial.println(d, HEX);
  if (d > 2)
    return;
  if (disk != NULL)
    delete disk;
  disk = NULL;
  if (sector_data != NULL)
    free(sector_data);
  sector_data = NULL;
  active = d;	
}

void CocoDisk::restore() {
  Serial.println("RESTORE");
  setRegister(FDCTRK, 0x00); // track 0
  setRegister(FDCSEC, 0x01); // sector 1
  
  setRegister(FDCSTAT, 0x04); // clear busy flag last
  track = 0;
  ddir = true;
  setNMI();
}

void CocoDisk::seek(uint16_t track) {
  this->track = track;
  Serial.print("SEEK ");
  Serial.println(track, HEX);
  setRegister(FDCTRK, track);
  setRegister(FDCSTAT, (track ? 0x00 : 0x04)); // Set track 0, clear busy
  setNMI();
}

void CocoDisk::step() {
  if (ddir)
    track++;
  else
    track--;
  Serial.print("STEP ");
  Serial.println(track, HEX);
  setRegister(FDCTRK, track);
  setRegister(FDCSTAT, (track ? 0x20 : 0x24));
  setNMI();
}

void CocoDisk::stepin() {
  Serial.print("STEP IN ");
  track--;
  ddir = false;
  if (track < 0)
    track = 0;
  setRegister(FDCTRK, track);
  setRegister(FDCSTAT, (track ? 0x20 : 0x24));
}

void CocoDisk::stepout() {
  Serial.print("STEP OUT ");
  track++;
  ddir = true;
  setRegister(FDCTRK, track);
  setRegister(FDCSTAT, 0x20);
  setNMI();
}

void CocoDisk::readSector(uint8_t side, uint8_t sector) {
  Serial.print("RSEC: ");
  Serial.print(side);
  Serial.print(", ");
  Serial.print(track, HEX);
  Serial.print(", ");
  Serial.println(sector, HEX);
  
  if (disk == NULL) {
    loadActiveImage();
    if (sector_data != NULL)
      free(sector_data);
    sector_size = disk->getSectorSize();
    sector_data = (char *)malloc(sector_size);
  }

  disk->getSector(side, track, sector, sector_data);
  
  for (uint16_t i = 0; i < sector_size; i++) {
    setRegister(FDCDAT, sector_data[i]);
    clearHALT();
    if (i != sector_size-1)
      waitDR();
  }
  setRegister(FDCSEC, sector);
  setRegister(FDCSTAT, 0x00);
  setNMI();
}

// Returns true if the config file needs reloading
boolean CocoDisk::writeSector(uint8_t side, uint8_t sector) {
  boolean result;
  
  if (disk == NULL) {
    loadActiveImage();
    sector_size = disk->getSectorSize();
    sector_data = (char *)malloc(sector_size);
  }

  for (uint16_t i=0; i < sector_size; i++) {
    setRegister(FDCSTAT, 0x03);
    if (i != 0)
      clearHALT();
    waitDR();
    loadFDCRegisters();
    sector_data[i] = fdcdat;
  }
  setRegister(FDCSEC, sector);
  setRegister(FDCSTAT, 0x00);
  setNMI();
  result = disk->putSector(side, track, sector, sector_data);
  return result;	
}

void CocoDisk::readAddress() {
  Serial.print("READ ADDRESS ");
  setRegister(FDCDAT, track);
  clearHALT();
  setRegister(FDCDAT, 0x00);
  clearHALT();
  setRegister(FDCDAT, 0x01); // Random sector
  clearHALT();
  setRegister(FDCDAT, 0x01);
  clearHALT();
  setRegister(FDCDAT, 0x00); // CRC1
  clearHALT();
  setRegister(FDCDAT, 0x00); // CRC2
  setRegister(FDCSTAT, 0x00); // clear BUSY
  setNMI();
}

void CocoDisk::readTrack() {
  setRegister(FDCSTAT, 0x80); // throw error
  setNMI();
}

void CocoDisk::writeTrack() {
  setRegister(FDCSTAT, 0x80); // throw error
  setNMI();
}

void CocoDisk::forceInt() {
  Serial.println("FORCE INT");
  setRegister(FDCSTAT, (track ? 0x00 : 0x04));
  //	setNMI(true);
}

// Wait until the DRO bit changes to 0
void CocoDisk::waitDR() {
  int i=0;
  loadStatus();
  while (fdcstat & 0x02) {
    loadStatus();
  }
}

void CocoDisk::loadActiveImage() {
  switch (active) {
  case 0:
    disk = new CocoImage(diskname1);
    break;
  case 1:
    disk = new CocoImage(diskname2);
    break;
  case 2:
    disk = new VirtualImage();
    break;
  default:
    Serial.println("no disk selected!");
    break;
  }
  if (disk == NULL) {
    Serial.println("Disk memory allocation failed");
    while (1);
  }
}
