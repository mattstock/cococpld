#ifndef COCODISK_H
#define COCODISK_H

#include "CocoImage.h"

class CocoDisk {
 public:
  
  CocoDisk();
  CocoDisk(const char *disk1, const char *disk2);
  ~CocoDisk();
  void setup(const char *disk1, const char *disk2);
  void setDrive(uint8_t d);
  void restore();
  void seek(uint16_t track);
  void step();
  void stepin();
  void stepout();
  void readSector(uint8_t side, uint8_t sector);
  boolean writeSector(uint8_t side, uint8_t sector);
  void readAddress();
  void readTrack();
  void writeTrack();
  void forceInt();
  
 protected:
  
  void waitDR();
  void loadActiveImage();
  
  char diskname1[13];
  char diskname2[13];
  CocoImage *disk;
  uint32_t track;
  boolean ddir;
  uint8_t active;
  uint16_t sector_size;
};

#endif
