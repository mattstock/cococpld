/*
 * firmware2.cpp
 *
 * Created: 4/20/2013 1:51:38 PM
 *  Author: stock
 */ 


#include <avr/io.h>
#include <Arduino.h>
#include "firmware2.h"
#include "rom.h"
#include "error.h"
#include "busio.h"

Adafruit_RGBLCDShield lcd;

// Keep a list of the files on the sdcard
int fileCount;
int fileIndex;
char names[MAX_FILES][13];

// Menu navigation
int menuIndex;


void displayFilename() {
	lcd.setCursor(0,1);
	lcd.print(clearMenu);
	lcd.setCursor(0,1);
	lcd.print(names[fileIndex]);
}

boolean fileSelect() {
	uint8_t buttons;
	
	// wait for button release
	while (lcd.readButtons());

	displayFilename();
	while (1) {
		if ((buttons = lcd.readButtons())) {
			if (buttons & BUTTON_LEFT)
			return false;
			if (buttons & BUTTON_UP) {
				if (fileIndex == 0)
				fileIndex = fileCount-1;
				else
				fileIndex--;
			}
			if (buttons & BUTTON_DOWN) {
				if (fileIndex == fileCount-1)
				fileIndex = 0;
				else
				fileIndex++;
			}
			if (buttons & BUTTON_SELECT)
			return true;
			displayFilename();
			delay(100);
		}
	}
}

void loadFiles() {
	File root = SD.open("/");
	if (!root) {
		lcd.clear();
		displayMsg(DIR_FAILED);
		delay(1000);
		return;
	}
	
	fileCount = 0;
	while (true) {
		File entry = root.openNextFile();
		if (!entry || (fileCount == MAX_FILES))
			break;
		if (!entry.isDirectory()) {
			strncpy(names[fileCount++], entry.name(), 13); // 8.3 and a null
			Serial.println(entry.name());
		}
		entry.close();
	}
	
	root.close();
}

void setup() {
	Serial.begin(115200);
	SPI.begin();
	SPI.setClockDivider(SPI_CLOCK_DIV4);
	SPI.setDataMode(SPI_MODE0);

	pinMode(2, INPUT); // For write flags
	pinMode(10, OUTPUT);
	digitalWrite(10, HIGH);
	pinMode(SDSELECT_PIN, OUTPUT);
	digitalWrite(SDSELECT_PIN, LOW);
			
	// Config LCD
	lcd = Adafruit_RGBLCDShield();
	lcd.begin(16, 2);
	lcd.clear();
	lcd.setBacklight(0x1);

	// sdcard setup
	if (!SD.begin(SDSELECT_PIN)) {
		displayMsg(CARD_FAILED);
		// don't do anything more:
		while (1);
	}
	
	loadFiles();
	
	if (fileCount == 0) {
		lcd.setCursor(0,1);
		displayMsg(NO_FILES);
		delay(2000);
	}
	
	setRegisters();
	
	menuIndex = 0;
	fileIndex = 0;
	lcd.clear();
	displayMenu(menuIndex);
}


// Prints a single bit in the right position on the LCD screen
void printAddress(uint16_t val) {
	for (int i=0; i < 16; i++) {
		lcd.setCursor(15-i, 1);
		lcd.print((val & (1 << i)) ? "1" : "0");
	}
}

void loop() {
	uint8_t buttons = lcd.readButtons();

	if (digitalRead(2)) // We have a write to a register
		readRegisters();
	if (buttons) {
		if (buttons & BUTTON_UP) {
			if (menuIndex == 0)
			menuIndex = menuCount-1;
			else
			menuIndex--;
		}
		if (buttons & BUTTON_DOWN) {
			if (menuIndex == menuCount-1)
			menuIndex = 0;
			else
			menuIndex++;
		}
		if (buttons & BUTTON_SELECT) {
			while (lcd.readButtons()); // Wait for release
			switch (menuIndex) {
			case 0:
				if (fileSelect())
					programROM(SD.open(names[fileIndex]));
				break;
			case 1:
				viewROM();
				break;
			case 2:
				if (fileSelect())
					verifyROM(SD.open(names[fileIndex]));
				break;
			case 3:
				eraseROM();
				break;
			case 4:
				printRegisters();
				break;
			}
			lcd.clear();
		}
		displayMenu(menuIndex);
		delay(100);
	}
}

extern void arduinomain(void);

int main(void) {
	arduinomain();
}
