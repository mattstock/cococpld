#ifndef _FIRMWARE2_H
#define _FIRMWARE2_H

#include <Wire.h>
#include <Adafruit_MCP23017.h>
#include <Adafruit_RGBLCDShield.h>
#include <SPI.h>
#include <SD.h>

// How many filenames we will be able to store
#define MAX_FILES 30

#define FLOPPY0 0
#define FLOPPY1 1
#define DSKROM  2
#define ROM     3
#define MAC     4

extern char *config[5];

extern Adafruit_RGBLCDShield lcd;
#endif
