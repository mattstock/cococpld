#include "rom.h"
#include "busio.h"
#include "firmware2.h"

int verifyROM(File dataFile) {
	uint16_t address;
	uint8_t stored;
	uint8_t disk;

	if (!dataFile)
		return -1;
	
	if (dataFile.size() <= 16*1024)
		address = 0xc000;
	else
		address = 0x8000;
	while (dataFile.available()) {
		disk = dataFile.read();
  		setAddress(address);
		stored = readData();
		if (stored != disk)
			return -1;

		address++;
	}
	
	dataFile.close();
	return 0;
}

void eraseROM() {			
	uint16_t address = 0x0000;
	setAddress(address);
	while (address != 0xffff) {
		setData(0x00);
		address++;
	}
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
	setAddress(address);
	
	while (dataFile.available()) {
		uint8_t d = dataFile.read();		
		setData(d);
		address++;
	}

	dataFile.close();
	return 0;
}
