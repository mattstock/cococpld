#include "rom.h"
#include "busio.h"
#include "firmware2.h"

void verifyROM(File dataFile) {
	uint16_t address;
	uint8_t stored;
	uint8_t disk;
	lcd.clear();

	if (!dataFile) {
		lcd.print("Open failed");
		return;
	}

	digitalWrite(BUSREQ_PIN, HIGH);
	pinMode(ARDRW_PIN, OUTPUT);
	digitalWrite(ARDRW_PIN, HIGH);
	
	setDataDir(INPUT);
	setAddrDir(OUTPUT);	
	
	if (dataFile.size() <= 16*1024)
	address = 0x4000;
	else
	address = 0x0000;
	while (dataFile.available()) {
		disk = dataFile.read();
		
		if (address % 0x100 == 0) {
			lcd.clear();
			lcd.print(address, HEX);
		}
		setAddress(address);
		digitalWrite(EEN_PIN, LOW);  // Enable output of eeprom
		stored = readData();
		digitalWrite(EEN_PIN, HIGH);
		if (stored != disk) {
			lcd.clear();
			lcd.print(address, HEX);
			lcd.print(": ");
			lcd.print(stored, HEX);
			lcd.print(" != ");
			lcd.print(disk, HEX);
			delay(500);
		}
		address++;
	}

	setAddrDir(INPUT);
	
	digitalWrite(BUSREQ_PIN, LOW);
	digitalWrite(EEN_PIN, HIGH);
	pinMode(ARDRW_PIN, INPUT);

	dataFile.close();

	lcd.clear();
	lcd.print("Verify complete");
	delay(2000);
}

// assumes the een is low, 
void programByte(uint16_t addr, uint8_t data) {
	int retry = 100;
	
	digitalWrite(EEN_PIN, HIGH);
	setAddress(addr);
	digitalWrite(ARDRW_PIN, LOW); // Latch address
	setDataDir(OUTPUT);
	setData(data);
	digitalWrite(ARDRW_PIN, HIGH); // Latch data
	
	// Check
	setDataDir(INPUT);
	digitalWrite(EEN_PIN, LOW);
	
	while ((retry != 0) & (readData() != data)) {
		retry--;
		digitalWrite(EEN_PIN, HIGH);
		delay(1);
		digitalWrite(EEN_PIN, LOW);
	}

	if (retry == 0) {
		lcd.clear();
		lcd.print("Err: 0x");
		lcd.print(addr, HEX);
		lcd.print(": ");
		lcd.print(data, HEX);
		delay(500);
	}
}

void eraseROM() {
	
	digitalWrite(BUSREQ_PIN, HIGH);
	pinMode(ARDRW_PIN, OUTPUT);
	digitalWrite(ARDRW_PIN, HIGH);
	digitalWrite(EEN_PIN, LOW);

	setAddrDir(OUTPUT);
	setDataDir(OUTPUT);
		
	uint16_t address = 0x0000;
	while (address < 0x8000) {
		if (address % 0x100 == 0) {
			lcd.clear();
			lcd.print("Erasing: 0x");
			lcd.print(address, HEX);
		}
		programByte(address, 0xff);
		address++;
	}

	setAddrDir(INPUT);
	pinMode(ARDRW_PIN, INPUT);

	digitalWrite(BUSREQ_PIN, LOW);
	digitalWrite(EEN_PIN, HIGH);
	
	lcd.clear();
	lcd.print("eeprom erased");
	delay(2000);
}

void viewROM() {
	digitalWrite(BUSREQ_PIN, HIGH); // disable coco addr lines
	pinMode(ARDRW_PIN, OUTPUT);
	digitalWrite(ARDRW_PIN, HIGH);
	
	setAddrDir(OUTPUT);
	setDataDir(INPUT);

	lcd.clear();
	lcd.print("0000");
	
	uint16_t address = 0x0000;
	while (address < 0x8000) {
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
		for (int i=0; i < 8; i++) {
			setAddress(address+i);
			digitalWrite(EEN_PIN, LOW);  // latch address
			lcd.setCursor(i*2,1);
			lcd.print(readData(), HEX);
			digitalWrite(EEN_PIN, HIGH);
		}
		
		while (1) {
			uint8_t buttons = lcd.readButtons();

			if (buttons) {
				if (buttons & BUTTON_SELECT) {
					setAddrDir(INPUT);
					digitalWrite(BUSREQ_PIN, LOW);
					return;
				}
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
	
	setAddrDir(INPUT);
	digitalWrite(BUSREQ_PIN, LOW);
	
	lcd.clear();
}

void programROM(File dataFile) {
	uint16_t address;
	
	lcd.clear();

	if (!dataFile) {
		lcd.print("Open failed");
		return;
	}
	
	digitalWrite(BUSREQ_PIN, HIGH); // disable coco address bus
	pinMode(ARDRW_PIN, OUTPUT);
	digitalWrite(ARDRW_PIN, HIGH);
	digitalWrite(EEN_PIN, LOW);
	
	setAddrDir(OUTPUT);
	setDataDir(OUTPUT);

	if (dataFile.size() <= 16*1024)
	address = 0x4000;
	else
	address = 0x0000;
	
	while (dataFile.available()) {
		uint8_t d = dataFile.read();
		
		if (address % 0x100 == 0) {
			lcd.setCursor(0,0);
			lcd.print("Prog: 0x");
			lcd.print(address, HEX);
			lcd.print(": ");
			lcd.print(d, HEX);
		}
		programByte(address, d);
		address++;
	}

	setAddrDir(INPUT);
	pinMode(ARDRW_PIN, INPUT);

	digitalWrite(BUSREQ_PIN, LOW);
	digitalWrite(EEN_PIN, HIGH);

	dataFile.close();
	
	lcd.clear();
	lcd.print("Program complete");
	delay(2000);
}
