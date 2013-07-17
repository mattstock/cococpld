/*
 * firmware2.cpp
 *
 * Created: 4/20/2013 1:51:38 PM
 *  Author: stock
 */ 


#include <avr/io.h>
#include <avr/interrupt.h> 
#include <Arduino.h>
#include "firmware2.h"
#include "rom.h"
#include "error.h"
#include "fdc.h"
#include "busio.h"

Adafruit_RGBLCDShield lcd;

// Keep a list of the files on the sdcard
int fileCount;
int fileIndex;
char *names[MAX_FILES];
char *config[5];

// Menu navigation
int menuIndex;

/*ISR({Vector Source}_vect) {
	// ISR code to execute here
}*/

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

	if (fileCount == 0)
	  return false;
	  
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
	char *name;
	File root = SD.open("/");
	if (!root) {
		lcd.clear();
		displayMsg(DIR_FAILED);
		delay(1000);
		return;
	}
	
	root.rewindDirectory();
	fileCount = 0;
	while (true) {
		File entry = root.openNextFile();
		if (!entry || (fileCount == MAX_FILES))
			break;
		if (!entry.isDirectory()) {
			name = entry.name();
			if (strncasecmp("ccc", &(name[strlen(name)-3]), 3))
				continue;
			names[fileCount] = (char *) malloc(14);
			strncpy(names[fileCount++], name, 13); // 8.3 and a null
			Serial.println(entry.name());
		}
		entry.close();
	}
}

void parseLine(char *line) {
	if (!strncmp("floppy0 ", line, 8)) {
		config[FLOPPY0] = (char *) malloc(13);
		strcpy(config[FLOPPY0], &(line[8]));
	}
	if (!strncmp("floppy1 ", line, 8)) {
		config[FLOPPY1] = (char *) malloc(13);
		strcpy(config[FLOPPY1], &(line[8]));
	}
	if (!strncmp("rom ", line, 4)) {
		config[ROM] = (char *) malloc(13);
		strcpy(config[ROM], &(line[4]));
	}
	if (!strncmp("floppy-rom ", line, 11)) {
		config[DSKROM] = (char *) malloc(13);
		strcpy(config[DSKROM], &(line[11]));
	}
}

// Pull data from setup.txt if available
void loadSetup() {
	File f = SD.open("setup.txt");
	char line[30];
	uint8_t idx = 0;
	
	if (!f)
	  return;

	Serial.println("Loading config file");
	
	for (int i=0; i < 7; i++)
		config[i] = NULL;
		
	while (f.available()) {
		line[idx++] = f.read();
		if (line[idx-1] == '\r') {
			idx--;
			continue;
		}
		if (line[idx-1] == '\n') {
			line[idx-1] = '\0';
#ifdef DEBUG
			Serial.print("Parsing = |");
			Serial.print(line);
			Serial.println("|");
#endif
			parseLine(line);
			idx = 0;
		}
	}
	f.close();
}

void setup() {
	Serial.begin(115200);
	SPI.begin();
	SPI.setClockDivider(SPI_CLOCK_DIV4);
	SPI.setDataMode(SPI_MODE0);

	pinMode(CMDINT_PIN, INPUT);
	pinMode(CFGINT_PIN, INPUT);
	pinMode(USBSELECT_PIN, OUTPUT);
	digitalWrite(USBSELECT_PIN, HIGH);
	pinMode(ETHSELECT_PIN, OUTPUT);
	digitalWrite(ETHSELECT_PIN, HIGH);
	pinMode(COCOSELECT_PIN, OUTPUT);
	digitalWrite(COCOSELECT_PIN, HIGH);
	pinMode(SDSELECT_PIN, OUTPUT);
	digitalWrite(SDSELECT_PIN, HIGH);
	
	// Config LCD
	lcd = Adafruit_RGBLCDShield();
	lcd.begin(16, 2);
	lcd.clear();
	lcd.setBacklight(0x1);

	// sdcard setup
	if (!SD.begin(SDSELECT_PIN)) {
		Serial.println("microSD failed");
		// don't do anything more:
		while (1);
	}

	loadSetup();

	//byte mac[] = { 0xE3, 0x4A, 0xBE, 0xC0, 0x3D, 0x3D };  // Load from setup file in the production version
	// Ethernet setup
	// Ethernet.begin(mac);
	
	loadFiles();
	
	if (fileCount == 0) {
		lcd.setCursor(0,1);
		displayMsg(NO_FILES);
		delay(2000);
	}
	
	loadRegisters();
	
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
				if (fileSelect())
					verifyROM(SD.open(names[fileIndex]));
				break;
			case 2:
				eraseROM();
				break;
			case 3:
				fdc();
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
