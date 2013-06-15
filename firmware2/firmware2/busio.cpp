#include "busio.h"
#include "rom.h"
#include <avr/io.h>

void setAddress(uint16_t addr) {
	digitalWrite(COCOSELECT_PIN, LOW);
	SPI.transfer(0x01);
	SPI.transfer((addr >> 8) & 0xff);
	SPI.transfer(addr & 0xff);
	digitalWrite(COCOSELECT_PIN, HIGH);
}

void setRegisters() {
	for (uint8_t i=0; i < 15; i++) {
		setAddress(0x7f40 + i);
		setData(0xa0+i);
	}
}

void readRegisters() {
	for (uint8_t i=0; i < 15; i++) {
		setAddress(0x7f40 + i);  // maps to 0xff40 in register space
		reg[i] = readData();
	}
}

uint8_t readData() {
	uint8_t b;
	
	digitalWrite(COCOSELECT_PIN, LOW);
	SPI.transfer(0x03);
	b = SPI.transfer(0xff);
	digitalWrite(COCOSELECT_PIN, HIGH);
	return b;
}

void setData(uint8_t b) {
	digitalWrite(COCOSELECT_PIN, LOW);
	SPI.transfer(0x02);
	SPI.transfer(b);
	digitalWrite(COCOSELECT_PIN, HIGH);
}
