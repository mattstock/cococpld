#include "rom.h"
#include "busio.h"
#include "firmware2.h"

int verifyROM(File dataFile) {
  uint16_t address;
  uint8_t stored;
  uint8_t disk;
  
  if (!dataFile) {
    Serial.println("datafile error");
    return -1;
  }
  
  if (dataFile.size() <= 16*1024)
    address = 0xc000;
  else
    address = 0x8000;
 
  setAddress(0xff50);
  setData(0x01);
  
  while (dataFile.available()) {
    disk = dataFile.read();
    setAddress(address);
    stored = readData();
    if (stored != disk) {
      Serial.print(address, HEX);
      Serial.print(": ");
      Serial.print(disk, HEX);
      Serial.print(" != ");
      Serial.println(stored, HEX);
      return -1;
    }
    address++;
  }
  
  setAddress(0xff50);
  setData(0x00);

  dataFile.close();
  return 0;
}

void eraseFlash() {
  uint8_t v1, v2;

  // Set program mode
  setAddress(0xff50);
  setData(0x01);

  // Flash chip erase
  setAddress(0x0aaa);
  setData(0xaa);
  setAddress(0x0555);
  setData(0x55);
  setAddress(0x0aaa);
  setData(0x80);
  setData(0xaa);
  setAddress(0x0555);
  setData(0x55);
  setAddress(0x0aaa);
  setData(0x10);

  setAddress(0xc000);
  while (readData() != 0xff);
  // TODO wait until erase is complete before continue!

  // Unset program mode
  setAddress(0xff50);
  setData(0x00);
}

void unlockFlash() {
  // Unlock bypass mode
  setAddress(0x0aaa);
  setData(0xaa);
  setAddress(0x0555);
  setData(0x55);
  setAddress(0x0aaa);
  setData(0x20);
}


int programROM(File dataFile) {
  uint16_t address;
  
  if (!dataFile)
    return -1;
  
  Serial.print("program: ");
  Serial.println(dataFile.name());	
  
  if (dataFile.size() <= 16*1024)
    address = 0xc000;
  else
    address = 0x8000;

  setAddress(0xff50);
  setData(0x01);

  // flashUnlock();
  while (dataFile.available()) {
    setData(0xa0);
    setAddress(address);
    uint8_t d = dataFile.read();		
    setData(d);
    while (readData() != d);
    address++;
  }

  setAddress(0xff50);
  setData(0x00);

  dataFile.close();
  return 0;
}
