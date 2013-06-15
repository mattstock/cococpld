#ifndef _BUSIO_H
#define _BUSIO_H

#include <Arduino.h>
#include <SPI.h>
 
#define ETHSELECT_PIN 10
#define SDSELECT_PIN 4
#define COCOSELECT_PIN 9
#define USBSELECT_PIN 53
#define WRITEINT_PIN 2
 
#define CLEAR(port, bit) port &= (0 << bit)
#define SET(port, bit) port |= (1 << bit)

void setAddress(uint16_t addr);
void readRegisters();
void setRegisters();

uint8_t readData();
void setData(uint8_t b);

#endif
