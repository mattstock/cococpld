#ifndef _BUSIO_H
#define _BUSIO_H

#include <Arduino.h>

#define CLEAR(port, bit) port &= (0 << bit)
#define SET(port, bit) port |= (1 << bit)

#define ARDRW_PIN 23
#define BUSREQ_PIN 24
#define EEN_PIN 49
#define ECLK_PIN 27
#define ETHSELECT_PIN 10
#define SDSELECT_PIN 4
#define SCS_PIN A15

void io_setup();
void setAddrDir(uint8_t mode);
void setDataDir(uint8_t mode);
uint16_t readAddress();
void setAddress(uint16_t addr);
uint8_t readData();
void setData(uint8_t b);

#endif
