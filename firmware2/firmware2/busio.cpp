#include "busio.h"
#include "rom.h"
#include "fdc.h"
#include <avr/io.h>

uint8_t reg[31];

void setAddress(uint16_t addr) {
	PORTC = (addr >> 8) & 0xff;
	PORTA = addr & 0xff;
}

void setRegister(uint8_t i, uint8_t d) {
	setAddress(i);
	reg[i] = d;
	setData(d);
 
}

void loadStatusReg() {
	setAddress(0x0011);
	reg[17] = readData(); 
}

void loadRegisters() {
	for (uint8_t i=2; i < 31; i++) { // pull from SPI
		setAddress(i);
		reg[i] = readData();
	}
}

void loadConfigReg() {
	setAddress(0x0000);
	reg[0] = readData();
}

uint8_t readData() {
	uint8_t b;
	
    DDRL = 0x00;
	digitalWrite(COCORW_PIN, HIGH);
	digitalWrite(COCOSELECT_PIN, LOW);
	b = PINL;
	digitalWrite(COCOSELECT_PIN, HIGH);
	return b;
}

void setData(uint8_t b) {
	digitalWrite(COCORW_PIN, LOW);
 	DDRL = 0xff;
 	PORTL = b;
	digitalWrite(COCOSELECT_PIN, LOW);
	digitalWrite(COCOSELECT_PIN, HIGH);
}

void setNMI() {
    setAddress(0x0100);
	setData(0x06); // clear halt enable register and trigger nmi
}

void wakeCoco() {
    setAddress(0x0100);
    setData(0x05); // clear halt enable register
}

void clearHALT() {
    setAddress(0x0100);
	setData(0x01); // clear halt
}
