#include "busio.h"
#include <avr/io.h>

void takeBus() {
	digitalWrite(10, LOW);
	SPI.transfer(0x04);
	digitalWrite(10, HIGH);
}

void giveBus() {
	digitalWrite(10, LOW);
	SPI.transfer(0x05);
	digitalWrite(10, HIGH);	
}

void setAddress(uint16_t addr) {
	digitalWrite(10, LOW);
	SPI.transfer(0x01);
	SPI.transfer((addr >> 8) & 0xff);
	SPI.transfer(addr & 0xff);
	digitalWrite(10, HIGH);
}

uint8_t readData() {
	uint8_t b;
	
	digitalWrite(10, LOW);
	SPI.transfer(0x03);
	b = SPI.transfer(0xff);
	digitalWrite(10, HIGH);
	return b;
}

void setData(uint8_t b) {
	digitalWrite(10, LOW);
	SPI.transfer(0x02);
	SPI.transfer(b);
	digitalWrite(10, HIGH);
}



