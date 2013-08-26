#ifndef _BUSIO_H
#define _BUSIO_H

#include <Arduino.h>
#include <SPI.h>
 
#define ETHSELECT_PIN 10
#define SDSELECT_PIN 4
#define COCORW_PIN 41
#define COCOSELECT_PIN 39
#define USBSELECT_PIN 53
#define CFGINT_PIN 2
#define CMDINT_PIN 3

#define CLEAR(port, bit) port &= (0 << bit)
#define SET(port, bit) port |= (1 << bit)

extern uint8_t reg[];

void setAddress(uint16_t addr);
void loadRegisters();
void loadStatusReg();
void loadConfigReg();
void setRegister(uint8_t i, uint8_t d);
void setNMI();
void clearHALT();

uint8_t readData();
void setData(uint8_t b);

#endif
