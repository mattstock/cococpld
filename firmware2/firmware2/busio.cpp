#include "busio.h"
#include "rom.h"
#include "fdc.h"
#include <avr/io.h>

volatile uint8_t reg[31];
volatile boolean controlPending;
volatile boolean commandPending;

void setAddress(uint16_t addr) {
	PORTC = (addr >> 8) & 0xff;
	PORTA = addr & 0xff;
}

void setRegister(uint8_t i, uint8_t d) {
	setAddress(i);
	reg[i] = d;
	setData(d);
 
}

// Load config register
void loadConfig() {
	if (controlPending)
		digitalWrite(7, HIGH);
	PORTC = 0x00;
	PORTA = 0x00;
	DDRL = 0x00;
	digitalWrite(COCORW_PIN, HIGH);
	digitalWrite(COCOSELECT_PIN, LOW);
	reg[0] = PINL;
	digitalWrite(COCOSELECT_PIN, HIGH);
	controlPending = true;
}

// Load command register
void loadCommand() {
	if (commandPending)
		digitalWrite(8, HIGH);
	PORTC = 0x00;
	PORTA = 0x10;
	DDRL = 0x00;
	digitalWrite(COCORW_PIN, HIGH);
	digitalWrite(COCOSELECT_PIN, LOW);
	reg[0x10] = PINL;
	digitalWrite(COCOSELECT_PIN, HIGH);
	commandPending = true;
}

void loadStatus() {
	setAddress(RW(FDCSTAT));
	reg[RW(FDCSTAT)] = readData(); 
}

void loadFDCRegisters() {
	setAddress(RR(FDCDAT));
	reg[RR(FDCDAT)] = readData();
	setAddress(RR(FDCSEC));
	reg[RR(FDCSEC)] = readData();
	setAddress(RR(FDCTRK));
	reg[RR(FDCTRK)] = readData();
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
