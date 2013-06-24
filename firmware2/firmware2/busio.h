#ifndef _BUSIO_H
#define _BUSIO_H

#include <Arduino.h>
#include <SPI.h>
 
#define ETHSELECT_PIN 10
#define SDSELECT_PIN 4
#define COCOSELECT_PIN 9
#define USBSELECT_PIN 53
#define WRITEINT_PIN 2
 
#define DSKREG 0xff40
#define FDCCMD 0xff48
#define FDCSTAT 0xff48
#define FDCTRK 0xff49
#define FDCSEC 0xff4a
#define FDCDAT 0xff4b
#define SECTORSIZE 336L
#define MAXSECTOR 18
#define MAXTRACK 35
#define TRACKSIZE (32+SECTORSIZE*MAXSECTOR+200)
#define RR(x) (2*(x-DSKREG))
#define RW(x) (2*(x-DSKREG)+1)

#define CLEAR(port, bit) port &= (0 << bit)
#define SET(port, bit) port |= (1 << bit)

void setAddress(uint16_t addr);
void readRegisters();
void loadRegisters();
void setRegister(uint8_t i, uint8_t d);
void setNMI(boolean s);
void setHALT(boolean s);

uint8_t readData();
void setData(uint8_t b);

#endif
