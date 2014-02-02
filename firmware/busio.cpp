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
  digitalWrite(COCOSELECT_PIN, LOW);
  digitalWrite(BANK1_ENABLE_PIN, LOW); // need to tristate MISO
  SPI.transfer(CMD_SET_ADDR);
  SPI.transfer((addr >> 8) & 0xff);
  SPI.transfer(addr & 0xff);
  digitalWrite(COCOSELECT_PIN, HIGH);
  digitalWrite(BANK1_ENABLE_PIN, HIGH); // need to tristate MISO
}

// Load config register
void loadConfig() {
  setAddress(DSKREG);
  dskreg = readData();
  controlPending = true;
}

void setRegister(uint16_t i, uint8_t d) {
  setAddress(i);
  setData(d);
  switch (i) {
  case DSKREG:
    dskreg = d;
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
  setAddress(FDCCMD);
  fdccmd = readData();
  commandPending = true;
}

void loadStatus() {
  ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
    fdcstat = readStatus();
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

uint8_t readStatus() {
  uint8_t tmp;

  digitalWrite(COCOSELECT_PIN, LOW);
  digitalWrite(BANK1_ENABLE_PIN, LOW); // need to tristate MISO
  SPI.transfer(CMD_READ_STATUS);
  tmp = SPI.transfer(0xff);
  digitalWrite(BANK1_ENABLE_PIN, HIGH); // need to tristate MISO
  digitalWrite(COCOSELECT_PIN, HIGH);
  return tmp;
}

uint8_t readData() {
  uint8_t b;
  
  ATOMIC_BLOCK(ATOMIC_FORCEON) {
    digitalWrite(COCOSELECT_PIN, LOW);
    digitalWrite(BANK1_ENABLE_PIN, LOW); // need to tristate MISO
    SPI.transfer(CMD_READ_BYTE);
    b = SPI.transfer(0xff);
  digitalWrite(BANK1_ENABLE_PIN, HIGH); // need to tristate MISO
    digitalWrite(COCOSELECT_PIN, HIGH);
  }
  return b;
}

void setData(uint8_t b) {
  ATOMIC_BLOCK(ATOMIC_FORCEON) {
    digitalWrite(COCOSELECT_PIN, LOW);
    digitalWrite(BANK1_ENABLE_PIN, LOW); // need to tristate MISO
    SPI.transfer(CMD_WRITE_BYTE);
    SPI.transfer(b);
    digitalWrite(BANK1_ENABLE_PIN, HIGH); // need to tristate MISO
    digitalWrite(COCOSELECT_PIN, HIGH);
  }
}

void setNMI() {
  ATOMIC_BLOCK(ATOMIC_FORCEON) {
    digitalWrite(COCOSELECT_PIN, LOW);
    digitalWrite(BANK1_ENABLE_PIN, LOW); // need to tristate MISO
    SPI.transfer(CMD_DEV_CONTROL);
    SPI.transfer(0b00001100);
    digitalWrite(BANK1_ENABLE_PIN, HIGH); // need to tristate MISO
    digitalWrite(COCOSELECT_PIN, HIGH);
  }
}

void wakeCoco() {
  ATOMIC_BLOCK(ATOMIC_FORCEON) {
    digitalWrite(COCOSELECT_PIN, LOW);
    SPI.transfer(CMD_DEV_CONTROL);
    SPI.transfer(0b00001010);
    digitalWrite(COCOSELECT_PIN, HIGH);
  }
}

void clearHALT() {
  ATOMIC_BLOCK(ATOMIC_FORCEON) {
    digitalWrite(COCOSELECT_PIN, LOW);
    digitalWrite(BANK1_ENABLE_PIN, LOW); // need to tristate MISO
    SPI.transfer(CMD_DEV_CONTROL);
    SPI.transfer(0b00000010);
    digitalWrite(BANK1_ENABLE_PIN, HIGH); // need to tristate MISO
    digitalWrite(COCOSELECT_PIN, HIGH);
  }
}
