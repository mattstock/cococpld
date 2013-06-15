#include "rom.h"
#include "busio.h"
#include "firmware2.h"
#include "error.h"

uint8_t reg[16];

void verifyROM(File dataFile) {
	uint16_t address;
	uint8_t stored;
	uint8_t disk;
	lcd.clear();

	if (!dataFile) {
		displayMsg(OPEN_FAILED);
		return;
	}
	
	if (dataFile.size() <= 16*1024)
		address = 0xc000;
	else
		address = 0x8000;
	while (dataFile.available()) {
		disk = dataFile.read();
  		setAddress(address);
		
		if (address % 0x100 == 0) {
			lcd.clear();
			lcd.print(address, HEX);
		}
		stored = readData();
		if (stored != disk) {
			lcd.clear();
			lcd.print(address, HEX);
			lcd.print(": ");
			lcd.print(stored, HEX);
			lcd.print(" != ");
			lcd.print(disk, HEX);
			delay(200);
		}
		address++;
	}
	
	dataFile.close();

	lcd.clear();
	displayMsg(VERIFY);
	displayMsg(COMPLETE);
	delay(2000);
}

void eraseROM() {			
	lcd.clear();
	displayMsg(ERASE);

	uint16_t address = 0x0000;
	setAddress(address);
	while (address != 0xffff) {
		setData(0x00);
		address++;
	}

	lcd.clear();
	displayMsg(ERASE);
	displayMsg(COMPLETE);
	delay(2000);
}

void printRegisters() {
	lcd.clear();
	for (uint8_t i=0; i < 4; i++) {
		lcd.setCursor(2*i, 1);
		lcd.print(reg[i], HEX);
	}
	delay(2000);
	while (lcd.readButtons());
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

void misc() {
	uint8_t d;
	
	lcd.clear();
	lcd.print("AA: C000 BB: D000");
	
	while (!lcd.readButtons()) {
		setAddress(0xc000);
        setData(0xaa);
		setAddress(0xc000);
		
		d = readData();
		if (d != 0xaa) {
			lcd.clear();
			lcd.print("c000: ");
			lcd.print(d,HEX);
			while (!lcd.readButtons());
			while (lcd.readButtons());
			lcd.clear();
		}
		setAddress(0xd000);
		setData(0xbb);
		setAddress(0xd000);
		d = readData();
		if (d != 0xbb) {
			lcd.clear();
			lcd.print("d000: ");
			lcd.print(d,HEX);
			while (!lcd.readButtons());
			while (lcd.readButtons());
			lcd.clear();
		}
	}
	
	while (lcd.readButtons());

	lcd.clear();
	lcd.print("CC: 7f40 DD: 7f50");
	
	while (!lcd.readButtons()) {
		setAddress(0x7f40);
		setData(0xcc);
		setAddress(0x7f40);
		
		d = readData();
		if (d != 0xcc) {
			lcd.clear();
			lcd.print("7f40: ");
			lcd.print(d,HEX);
			while (!lcd.readButtons());
			while (lcd.readButtons());
			lcd.clear();
		}
		setAddress(0x7f50);
		setData(0xdd);
		setAddress(0x7f50);
		d = readData();
		if (d != 0xdd) {
			lcd.clear();
			lcd.print("7f50: ");
			lcd.print(d,HEX);
			while (!lcd.readButtons());
			while (lcd.readButtons());
			lcd.clear();
		}
	}	
}

void programROM(File dataFile) {
	uint16_t address;
	
	lcd.clear();

	if (!dataFile) {
		displayMsg(OPEN_FAILED);
		return;
	}
	
	if (dataFile.size() <= 16*1024)
	address = 0xc000;
	else
	address = 0x8000;	
	setAddress(address);
	
	while (dataFile.available()) {
		uint8_t d = dataFile.read();
		
		if (address % 0x100 == 0) {
			lcd.setCursor(0,0);
			lcd.print("Prog: 0x");
			lcd.print(address, HEX);
			lcd.print(": ");
			lcd.print(d, HEX);
		}
		setData(d);
		address++;
	}

	dataFile.close();
	
	lcd.clear();
	displayMsg(PROGRAMMING);
	displayMsg(COMPLETE);
	delay(2000);
}
