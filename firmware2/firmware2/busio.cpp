#include "busio.h"
#include "rom.h"
#include <avr/io.h>

void takeBus() {
/*	digitalWrite(10, LOW);
	SPI.transfer(0x04);
	while (SPI.transfer(0xff));
	digitalWrite(10, HIGH);*/
}

void giveBus() {
/*	digitalWrite(10, LOW);
	SPI.transfer(0x05);
	digitalWrite(10, HIGH);	*/
}

void setAddress(uint16_t addr) {
	digitalWrite(10, LOW);
	SPI.transfer(0x01);
	SPI.transfer((addr >> 8) & 0xff);
	SPI.transfer(addr & 0xff);
	digitalWrite(10, HIGH);
}

void setRegisters() {
	takeBus();
	for (uint8_t i=0; i < 15; i++) {
		setAddress(0x7f40 + i);
		setData(0xa0+i);
	}
	giveBus();
}
void readRegisters() {
	takeBus();
	for (uint8_t i=0; i < 15; i++) {
		setAddress(0x7f40 + i);  // maps to 0xff40 in register space
		reg[i] = readData();
	}
	
	digitalWrite(3, reg[0] < 0x80);
	 
	giveBus();
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

void nopSPI() {
	digitalWrite(10, LOW);
	SPI.transfer(0xee);
	digitalWrite(10, HIGH);
}
