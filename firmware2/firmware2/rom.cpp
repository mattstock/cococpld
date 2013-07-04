#include "rom.h"
#include "busio.h"
#include "firmware2.h"
#include "error.h"

uint8_t reg[30];

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

void viewROM() {
	lcd.clear();
	lcd.print("0000");
	
	uint16_t address = 0x0000;
	while (true) {
		if (address < 0x10)
		lcd.setCursor(3,0);
		else if (address < 0x100)
		lcd.setCursor(2,0);
		else if (address < 0x1000)
		lcd.setCursor(1,0);
		else
		lcd.setCursor(0,0);
		lcd.print(address, HEX);
		lcd.print(":");
		
		lcd.setCursor(0,1);
		lcd.print("0000000000000000");
		setAddress(address);
		for (int i=0; i < 8; i++) {
			lcd.setCursor(i*2,1);
			lcd.print(readData(), HEX);
		}
		
		while (1) {
			uint8_t buttons = lcd.readButtons();

			if (buttons) {
				if (buttons & BUTTON_SELECT)
					return;
				if (buttons & BUTTON_UP)
					address += 0x1000;
				if (buttons & BUTTON_RIGHT)
					address += 8;
				if (buttons & BUTTON_LEFT)
					address -= 8;
				if (buttons & BUTTON_DOWN)
					address -= 0x1000;
				break;
			}
		}
	}
	
	lcd.clear();
}

int programROM(File dataFile) {
	uint16_t address;
	
	if (!dataFile)
		return -1;
	
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
