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
#include "fdc.h"
#include "busio.h"

char *config[5];

/*ISR({Vector Source}_vect) {
	// ISR code to execute here
}*/


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
	
	loadRegisters();
	
	Serial.print("Going into fdc");
	fdc();
	Serial.print("Fail");
	while (1);
}

void loop() {
}

extern void arduinomain(void);

int main(void) {
	arduinomain();
}
