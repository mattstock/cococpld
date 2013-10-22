#ifndef _BUSIO_H
#define _BUSIO_H

#include <Arduino.h>
#include <SPI.h>
 
#define ETHSELECT_PIN 10
#define SDSELECT_PIN 4
#define COCORW_PIN 41
#define COCOSELECT_PIN 38 // 39 on v2.0 hardware, 38 on FPGA board/mega
#define USBSELECT_PIN 53
#define CFGINT_PIN 2
#define CMDINT_PIN 3

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

uint8_t readData();
void setData(uint8_t b);

#endif
