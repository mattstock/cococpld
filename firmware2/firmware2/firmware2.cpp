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

const char menu[][20] = { "program", "view", "verify", "erase", "slave", "bits" };
const int menuCount = 6;

// Keep a list of the files on the sdcard
int fileCount;
int fileIndex;
char names[MAX_FILES][13];

// Menu navigation
int menuIndex;

volatile uint8_t pl, pg, pc, pa, pd, ddrg, ddrd;
volatile bool newstuff = false;

ISR(PCINT2_vect) {
	if (newstuff) // only want rising edge
	  return;
	  
	// Quick grab of all of the relevant IO ports.  We can sort and rearrange them later.
	pl = PINL;
	pg = PING;
	ddrg = DDRG;
	ddrd = DDRD;
	pc = PINC;
	pd = PIND;
	pa = PINA;
	newstuff = true;	
}

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

void bitfiddler() {
}

void slaveMode() {
	char address[30];
	uint8_t buttons;
	uint8_t d;
	uint16_t a;
	uint16_t count;
	
	// Should already be like this, but just in case...
	pinMode(ARDRW_PIN, INPUT);
	digitalWrite(EEN_PIN, HIGH);
	digitalWrite(BUSREQ_PIN, LOW);
 	setDataDir(INPUT);
 	setAddrDir(INPUT);

	lcd.clear();
	newstuff = false;
	count = 0xff40;
	
	PCMSK2 |= 0x80;
	PCICR |= 0x04;
	
	while (1) {
		buttons = lcd.readButtons();
		if (buttons & BUTTON_SELECT)
			break;
		if (newstuff) {
			d = (pl >> 1) | ((pg & 0x01) << 7); // What a mess
			lcd.print(d, HEX);
			a =  (pc << 3) & 0b00011000;
			a |= (pd >> 5) & 0b00000100;
			a |= (pg >> 1) & 0b00000011;
			sprintf(address, "%04x =? %04x", a, count & 0b00011111);
			Serial.println(address);
			/*
			lcd.setCursor(0,1);
			lcd.print(address);
			lcd.setCursor(8,0);
			lcd.print(count++, HEX);
			lcd.setCursor(0,0);
			*/
			count++;
			newstuff = false;
		}
	}
	
	PCICR &= !(0x04);
	
	lcd.clear();
	lcd.print("slave quit");
	delay(2000);
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
				slaveMode();
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
