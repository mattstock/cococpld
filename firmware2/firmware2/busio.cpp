#include "busio.h"
#include <avr/io.h>

const int dataPins[] = { 48, 47, 46, 45, 44, 43, 42, 41 };
const int addrPins[] = { 22, 23, 24, 25, 26, 27, 28, 29, 37, 36, 35, 34, 33, 32, 31 }; // PORTA, PORTC

void setDataDir(uint8_t mode) {
	for (int i=0; i < 8; i++)
		pinMode(dataPins[i], mode);
}

void setAddrDir(uint8_t mode) {
	for (int i=0; i < 15; i++)
		pinMode(addrPins[i], mode);
}

void io_setup() {
	pinMode(EEN_PIN, OUTPUT);
	digitalWrite(EEN_PIN, HIGH); // disable eeprom output
	pinMode(BUSREQ_PIN, OUTPUT);
	digitalWrite(BUSREQ_PIN, LOW); // don't disable coco address lines
	pinMode(ETHSELECT_PIN, OUTPUT);
	digitalWrite(ETHSELECT_PIN, HIGH); // disable ethernet for now
	pinMode(SDSELECT_PIN, OUTPUT);
	pinMode(ABUSMASTER_PIN, INPUT);
	pinMode(ABUSEN_PIN, INPUT);
	
	// Set everything as inputs to start
	pinMode(ARDRW_PIN, OUTPUT);
	digitalWrite(ARDRW_PIN, HIGH);
	setDataDir(INPUT);
	setAddrDir(INPUT);
}

uint16_t readAddress() {
	uint16_t a = 0;

	for (int i=0; i < 15; i++) {
		a = a + (digitalRead(addrPins[i]) << i);
	}
	return a;
}

void setAddress(uint16_t addr) {
	for (int i=0; i < 15; i++) {
		digitalWrite(addrPins[i], addr & 0x1);
		addr = addr >> 1;
	}
}

uint8_t readData() {
	uint8_t b = 0;
	
	for (int i=0; i < 8; i++) {
		b = b + (digitalRead(dataPins[i]) << i);
	}
	return b;
}

void setData(uint8_t b) {
	for (int i=0; i < 8; i++) {
		digitalWrite(dataPins[i], b & 0x1);
		b = b >> 1;
	}
}



