#ifndef _BUSIO_H
#define _BUSIO_H

#include <Arduino.h>
#include <SPI.h>
 
#define ETHSELECT_PIN 10
#define SDSELECT_PIN 4
#define LED_PIN 39
#define COCOSELECT_PIN 37
#define USBSELECT_PIN 53
#define CFGINT_PIN 2
#define CMDINT_PIN 3
#define CMDETH_PIN 22
#define BANK0_ENABLE_PIN A0
#define BANK1_ENABLE_PIN A1
#define BANK2_ENABLE_PIN A2
#define BANK3_ENABLE_PIN A3
#define CMD_SET_ADDR 0x01
#define CMD_WRITE_BYTE 0x02
#define CMD_READ_BYTE 0x03
#define CMD_READ_STATUS 0x04
#define CMD_DEV_CONTROL 0x05

extern volatile uint8_t dskreg;
extern volatile uint8_t fdcstat;
extern volatile uint8_t fdccmd;
extern volatile uint8_t fdctrk;
extern volatile uint8_t fdcsec;
extern volatile uint8_t fdcdat;
extern volatile boolean controlPending;
extern volatile boolean commandPending;

void setAddress(uint16_t addr);
void loadFDCRegisters();
void loadStatus();
void loadConfig();
void loadCommand();
void setRegister(uint16_t i, uint8_t d);
void setNMI();
void wakeCoco();
void clearHALT();

uint8_t readStatus();
uint8_t readData();
void setData(uint8_t b);

#endif
