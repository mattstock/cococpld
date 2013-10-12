#ifndef _BUSIO_H
#define _BUSIO_H

#include <Arduino.h>
#include <SPI.h>
 
#define ETHSELECT_PIN 10
#define SDSELECT_PIN 4
#define COCORW_PIN 41
#define COCOSELECT_PIN 38 // 39 on v2.0 hardware!
#define USBSELECT_PIN 53
#define CFGINT_PIN 2
#define CMDINT_PIN 3

#define CLEAR(port, bit) port &= (0 << bit)
#define SET(port, bit) port |= (1 << bit)

extern volatile uint8_t reg[];
extern volatile boolean controlPending;
// Ring buffer for commands, why not!?
extern volatile uint8_t cmdcnt;
extern volatile uint8_t cmdlist[];

void setAddress(uint16_t addr);
void loadFDCRegisters();
void loadStatus();
void loadConfig();
void loadCommand();
void dumpCommands();
void setRegister(uint8_t i, uint8_t d);
void setNMI();
void wakeCoco();
void clearHALT();

uint8_t readData();
void setData(uint8_t b);

#endif
