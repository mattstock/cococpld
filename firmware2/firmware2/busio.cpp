#include "busio.h"
#include "rom.h"
#include "fdc.h"
#include <avr/io.h>

uint8_t reg[31];

void setAddress(uint16_t addr) {
	digitalWrite(COCOSELECT_PIN, LOW);
	SPI.transfer(0x01);
	SPI.transfer((addr >> 8) & 0xff);
	SPI.transfer(addr & 0xff);
	digitalWrite(COCOSELECT_PIN, HIGH);
}

void setRegister(uint8_t i, uint8_t d) {
	setAddress(i);
	reg[i] = d;
	setData(d);
}

void loadRegisters() {
	for (uint8_t i=0; i < 31; i++) { // pull from SPI
		setAddress(i);
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

void setNMI(boolean s) {
	digitalWrite(COCOSELECT_PIN, LOW);
	SPI.transfer(s ? 0x04 : 0x05);
	digitalWrite(COCOSELECT_PIN, HIGH);
}

void setHALT(boolean s) {
	
	digitalWrite(COCOSELECT_PIN, LOW);
	SPI.transfer(s ? 0x06 : 0x07);
	digitalWrite(COCOSELECT_PIN, HIGH);
}