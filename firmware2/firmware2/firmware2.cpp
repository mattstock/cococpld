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
#include "busio.h"

Adafruit_RGBLCDShield lcd;

const char menu[][20] = { "program", "view", "verify", "erase", "check", "bits" };
const int menuCount = 6;

// Keep a list of the files on the sdcard
int fileCount;
int fileIndex;
char names[MAX_FILES][13];

// Menu navigation
int menuIndex;

volatile bool newstuff = false;

void displayMenu() {
	lcd.setCursor(0,0);
	lcd.print("              ");
	lcd.setCursor(0,0);
	lcd.print(menu[menuIndex]);
}

void displayFilename() {
	lcd.setCursor(0,1);
	lcd.print("             ");
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
		lcd.print("Dir failed");
		delay(1000);
		return;
	}
	
	fileCount = 0;
	while (true) {
		File entry = root.openNextFile();
		if (!entry || (fileCount == MAX_FILES))
		break;
		if (!entry.isDirectory())
		strncpy(names[fileCount++], entry.name(), 13); // 8.3 and a null
		entry.close();
	}
	
	root.close();
}

void setup() {
	Serial.begin(115200);
	io_setup();
	
	// Config LCD
	lcd = Adafruit_RGBLCDShield();
	lcd.begin(16, 2);
	lcd.clear();
	lcd.setBacklight(0x1);

	// sdcard setup
	if (!SD.begin(SDSELECT_PIN)) {
		lcd.print("Card fail or np");
		// don't do anything more:
		while (1);
	}
	loadFiles();
	if (fileCount == 0) {
		lcd.setCursor(0,1);
		lcd.print("no files");
		delay(2000);
	}
	
	menuIndex = 0;
	fileIndex = 0;
	lcd.clear();
	displayMenu();
}


// Prints a single bit in the right position on the LCD screen
void printAddress(uint16_t val) {
	for (int i=0; i < 16; i++) {
		lcd.setCursor(15-i, 1);
		lcd.print((val & (1 << i)) ? "1" : "0");
	}
}

uint16_t selectHex(int n) {
	uint8_t buttons;
	int digit = 2*n-1;
	uint16_t result;
	uint8_t vals[4] = {0,0,0,0};
	
	while (lcd.readButtons());

	lcd.cursor();
	
	lcd.setCursor(0,1);
	for (int i=0; i < n; i++)
		lcd.print("00");
	  
	while (1) {
		buttons = lcd.readButtons();
		if (buttons & BUTTON_SELECT)
			break;
		if (buttons & BUTTON_LEFT) {
			if (digit == 2*n-1)
				digit = 0;
			else
				digit++;
		}				
		if (buttons & BUTTON_RIGHT) {
			if (digit == 0)	
				digit = 2*n-1;
			else
				digit--;
		}			
		if (buttons & BUTTON_DOWN) {
			if (vals[digit] == 0)
				vals[digit] = 0xf;
			else
				vals[digit]--;
			lcd.print(vals[digit], HEX);
		}
		if (buttons & BUTTON_UP) {
			if (vals[digit] == 15)
				vals[digit] = 0;
			else
				vals[digit]++;
			lcd.print(vals[digit], HEX);
		}			
		lcd.setCursor(2*n-1-digit,1);
		delay(100);
	}
	
	result = 0;
	for (int i=0; i < 2*n; i++)
	  result = result | (vals[i] << i*4);
	  
	lcd.noCursor();	
	
	return result;
}

void bitfiddler() {
	lcd.clear();
	lcd.print("Address:");
	uint16_t a = selectHex(2);
	lcd.clear();
	lcd.print("Data:");
	uint8_t d = selectHex(1);
	
	digitalWrite(BUSREQ_PIN, HIGH); // disable coco address bus
	pinMode(ARDRW_PIN, OUTPUT);
	digitalWrite(ARDRW_PIN, HIGH);
	digitalWrite(EEN_PIN, LOW);
	
	setAddrDir(OUTPUT);
	setDataDir(OUTPUT);

	programByte(a, d);

	setAddrDir(INPUT);
	pinMode(ARDRW_PIN, INPUT);

	digitalWrite(BUSREQ_PIN, LOW);
	digitalWrite(EEN_PIN, HIGH);
}

void loop() {
	uint8_t buttons = lcd.readButtons();

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
				checkFail();
				break;
			case 5:
				bitfiddler();
				break;
			}
			lcd.clear();
		}
		displayMenu();
		delay(100);
	}
}

extern void arduinomain(void);

int main(void) {
	arduinomain();
}
