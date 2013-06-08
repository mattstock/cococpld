#ifndef _BUSIO_H
#define _BUSIO_H

#include <Arduino.h>
#include <SPI.h>
 
#define CLEAR(port, bit) port &= (0 << bit)
#define SET(port, bit) port |= (1 << bit)

void setAddress(uint16_t addr);
void readRegisters();
void setRegisters();

uint8_t readData();
void setData(uint8_t b);
void takeBus();
void giveBus();

#endif
