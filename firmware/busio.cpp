#include "busio.h"
#include "rom.h"
#include "fdc.h"
#include <avr/io.h>
#include <util/atomic.h>

volatile uint8_t reg[31];
volatile boolean controlPending;
volatile uint8_t cmdcnt = 0;
volatile uint8_t cmdlist[256];

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
	PORTC = 0x00;
	PORTA = RR(FDCCMD);
	DDRL = 0x00;
	digitalWrite(COCORW_PIN, HIGH);
	digitalWrite(COCOSELECT_PIN, LOW);
	cmdlist[cmdcnt++] = PINL;
	digitalWrite(COCOSELECT_PIN, HIGH);
}

void dumpCommands() {
	uint8_t m;

	m = cmdcnt; // copy the index to avoid atomicity issues
	for (uint8_t i=0; i < m; i++) {
		Serial.print(cmdlist[i], HEX);
		Serial.print(", ");
	}
	Serial.println();
}

void loadStatus() {
	PORTC = 0x00;
	PORTA = RW(FDCSTAT);
	DDRL = 0x00;
	digitalWrite(COCORW_PIN, HIGH);
	digitalWrite(COCOSELECT_PIN, LOW);
	reg[RW(FDCSTAT)] = PINL; 
	digitalWrite(COCOSELECT_PIN, HIGH);
}

void loadFDCRegisters() {
	PORTC = 0x00;
	DDRL = 0x00;
	digitalWrite(COCORW_PIN, HIGH);
	PORTA = RR(FDCDAT);
	digitalWrite(COCOSELECT_PIN, LOW);
	reg[RR(FDCDAT)] = PINL;
	digitalWrite(COCOSELECT_PIN, HIGH);
	PORTA = RR(FDCSEC);
	digitalWrite(COCOSELECT_PIN, LOW);
	reg[RR(FDCSEC)] = PINL;
	digitalWrite(COCOSELECT_PIN, HIGH);
	PORTA = RR(FDCTRK);
	digitalWrite(COCOSELECT_PIN, LOW);
	reg[RR(FDCTRK)] = PINL;
	digitalWrite(COCOSELECT_PIN, HIGH);
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
	setData(0x06); // clear halt enable register, and trigger nmi
}

void wakeCoco() {
    setAddress(0x0100);
    setData(0x05); // clear halt enable register, clear halt
}

void clearHALT() {
    setAddress(0x0100);
	setData(0x01); // clear halt
}
