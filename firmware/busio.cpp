#include "busio.h"
#include "rom.h"
#include "fdc.h"
#include <avr/io.h>
#include <util/atomic.h>

volatile uint8_t dskreg;
volatile uint8_t fdcstat;
volatile uint8_t fdccmd;
volatile uint8_t fdctrk;
volatile uint8_t fdcsec;
volatile uint8_t fdcdat;
volatile boolean controlPending;
volatile boolean commandPending;

void setAddress(uint16_t addr) {
  PORTC = (addr >> 8) & 0xff;
  PORTA = addr & 0xff;
}

// Load config register
void loadConfig() {
  if (controlPending)
    digitalWrite(9, HIGH);
  PORTC = (DSKREG >> 8) & 0xff;
  PORTA = DSKREG & 0xff;
  DDRL = 0x00;
  digitalWrite(COCORW_PIN, HIGH);
  digitalWrite(COCOSELECT_PIN, LOW);
  dskreg = PINL;
  digitalWrite(COCOSELECT_PIN, HIGH);
  controlPending = true;
}

void setRegister(uint16_t i, uint8_t d) {
  setAddress(i);
  setData(d);
  switch (i) {
  case DSKREG:
    dskreg = d;
    break;
  case FDCSTAT:
    fdcstat = d;
    break;
  case FDCCMD:
    fdccmd = d;
    break;
  case FDCTRK:
    fdctrk = d;
    break;
  case FDCSEC:
    fdcsec = d;
    break;
  case FDCDAT:
    fdcdat = d;
    break;
  }
}

// Load command register
void loadCommand() {
  PORTC = (FDCCMD >> 8) & 0xff;
  PORTA = FDCCMD & 0xff;
  DDRL = 0x00;
  digitalWrite(COCORW_PIN, HIGH);
  digitalWrite(COCOSELECT_PIN, LOW);
  fdccmd = PINL;
  digitalWrite(COCOSELECT_PIN, HIGH);
  commandPending = true;
}

void loadStatus() {
  PORTC = (FDCSTAT >> 8) & 0xff;
  PORTA = FDCSTAT & 0xff;
  DDRL = 0x00;
  digitalWrite(COCORW_PIN, HIGH);

  ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
    digitalWrite(COCOSELECT_PIN, LOW);
    fdcstat = PINL; 
    digitalWrite(COCOSELECT_PIN, HIGH);
  }
}

void loadFDCRegisters() {
  setAddress(FDCDAT);
  fdcdat = readData();
  setAddress(FDCSEC);
  fdcsec = readData();
  setAddress(FDCTRK);
  fdctrk = readData();
}

uint8_t readData() {
  uint8_t b;
  
  DDRL = 0x00;
  digitalWrite(COCORW_PIN, HIGH);
  ATOMIC_BLOCK(ATOMIC_FORCEON) {
    digitalWrite(COCOSELECT_PIN, LOW);
    b = PINL;
    digitalWrite(COCOSELECT_PIN, HIGH);
  }
  return b;
}

void setData(uint8_t b) {
  digitalWrite(COCORW_PIN, LOW);
  DDRL = 0xff;
  PORTL = b;
  ATOMIC_BLOCK(ATOMIC_FORCEON) {
    digitalWrite(COCOSELECT_PIN, LOW);
    digitalWrite(COCOSELECT_PIN, HIGH);
  }
  digitalWrite(COCORW_PIN, HIGH);
}

void setNMI() {
  setAddress(MAGIC);
  setData(0x06); // clear halt enable register, and trigger nmi
}

void wakeCoco() {
  setAddress(MAGIC);
  setData(0x05); // clear halt enable register, clear halt
}

void clearHALT() {
  setAddress(MAGIC);
  setData(0x01); // clear halt
}
