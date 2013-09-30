/*
 * firmware2.cpp
 *
 * Created: 4/20/2013 1:51:38 PM
 *  Author: stock
 */ 


#include <avr/io.h>
#include <avr/interrupt.h> 
#include <Arduino.h>
#include <Ethernet.h>
#include "firmware2.h"
#include "rom.h"
#include "fdc.h"
#include "busio.h"

char *config[MAX_CONFIG];

void parseLine(char *line) {
	if (!strncmp("floppy0 ", line, 8)) {
//		if (config[FLOPPY0] != NULL)
//			free(config[FLOPPY0]);
		config[FLOPPY0] = (char *) malloc(13);
		strncpy(config[FLOPPY0], &(line[8]), 13);
	}
	if (!strncmp("floppy1 ", line, 8)) {
//		if (config[FLOPPY1] != NULL)
//			free(config[FLOPPY1]);
		config[FLOPPY1] = (char *) malloc(13);
		strncpy(config[FLOPPY1], &(line[8]), 13);
	}
	if (!strncmp("rom ", line, 4)) {
//		if (config[ROM] != NULL)
//			free(config[ROM]);
		config[ROM] = (char *) malloc(13);
		strncpy(config[ROM], &(line[4]), 13);
	}
	if (!strncmp("floppy-rom ", line, 11)) {
//		if (config[DSKROM] != NULL)
//			free(config[DSKROM]);
		config[DSKROM] = (char *) malloc(13);
		strncpy(config[DSKROM], &(line[11]),13);
	}
}

// Pull data from setup.txt if available
void loadSetup() {
	File f = SD.open("setup.txt");
	char line[30];
	uint8_t idx = 0;
	
	if (!f)
	  return;

	for (int i=0; i < MAX_CONFIG; i++)
		config[i] = NULL;

	Serial.println("Loading config file");
	
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
	// Serial port for debugging output
	Serial.begin(115200);
	Serial1.begin(115200);
	
	// SPI used for microSD and WizNet (if plugged in)
	SPI.begin();
	SPI.setClockDivider(SPI_CLOCK_DIV4);
	SPI.setDataMode(SPI_MODE0);

	// Mode pin - not standard Arduino pin
	CLEAR(DDRE, PE6);
	SET(PORTE, PE6); // use pullup

    // Configure address, data, and signal lines
    DDRL = 0x00; // Data bus set to inputs for now
    PORTL = 0x00; // No pullups

	// To signal we have something for the CPLD
	pinMode(COCOSELECT_PIN, OUTPUT);
	digitalWrite(COCOSELECT_PIN, HIGH);
	
	DDRA = 0xff; // Address lines L
    DDRC = 0xff; // Address lines H

    pinMode(COCORW_PIN, OUTPUT);
	digitalWrite(COCORW_PIN, HIGH);

	// Configure these as interrupts eventually
	pinMode(CMDINT_PIN, INPUT);
	pinMode(CFGINT_PIN, INPUT);
	
	// Default SS pin - set to known state
	pinMode(USBSELECT_PIN, OUTPUT);
	digitalWrite(USBSELECT_PIN, HIGH);
	
	// For Wiznet module SPI select
	pinMode(ETHSELECT_PIN, OUTPUT);
	digitalWrite(ETHSELECT_PIN, HIGH);
	
	// microSD SPI select
	pinMode(SDSELECT_PIN, OUTPUT);
	digitalWrite(SDSELECT_PIN, HIGH);
	
	// A couple of debug pins
	pinMode(7, OUTPUT);
	digitalWrite(7, LOW);
	pinMode(8, OUTPUT);
	digitalWrite(8, LOW);
	
	Serial.print("Ram: ");
	Serial.println(FreeRam());

	// sdcard setup
	if (!SD.begin(SDSELECT_PIN)) {
		Serial.println("microSD failed");
		// don't do anything more:
		while (1);
	}

	loadSetup();

	if (PINE & (1 << PE6)) {
		Serial.println("Peripheral mode");
		commandPending = false;
		controlPending = false;
		attachInterrupt(0, loadConfig, HIGH);
		attachInterrupt(1, loadCommand, HIGH);
		fdc();
	}
	
	// Go into the loop for the test mode
	Serial.println("Test mode");
	programROM(SD.open(config[ROM]));
	wakeCoco();

//	while (1);
}

char cmd[30];

void readLine() {
	int index = 0;
	
	while (1) {
		if (Serial.available() > 0) {
			cmd[index] = Serial.read();
			cmd[index+1] = '\0';
			Serial.write(&(cmd[index]));
			if (cmd[index] == '\r') {
				Serial.println("");
				cmd[index] = '\0';
				index = 0;
				return;
			}
			index++;
		}
		
	}
	
}

char a2h(char c) {
	if (c < 'a') {
		return c-48;
	} else {
		return c-97+10;
	}
}

void loop() {
/*	if (Serial.available() > 0) {
		a[0] = Serial.read();
		a[1] = '\0';
		Serial1.write(a);
	}
	if (Serial1.available() >0) {
		a[0] = Serial1.read();
		a[1] = '\0';
		Serial.write(a);
	}*/
	Serial.print("BEXKAT> ");
	readLine();
	switch (cmd[0]) {
	case 'r':
		Serial.println(readData(), HEX);
		break;
	case 'w':
		setData((a2h(cmd[1]) << 4) + a2h(cmd[2]));
		Serial.println("Data written");
		break;
	case 'x':
		programROM(SD.open(config[ROM]));
		Serial.println("ROM programmed");
		break;
	case 'e':
		eraseROM();
		Serial.println("SRAM erased");
		break;
	case 'a':
		PORTC = (a2h(cmd[1]) << 4) + a2h(cmd[2]);
		PORTA = (a2h(cmd[3]) << 4) + a2h(cmd[4]);
		Serial.println("Address set");
		break;
	}
}

extern void arduinomain(void);

int main(void) {
	arduinomain();
}
