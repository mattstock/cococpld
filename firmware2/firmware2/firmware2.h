#ifndef _FIRMWARE2_H
#define _FIRMWARE2_H

#include <Wire.h>
#include <Adafruit_MCP23017.h>
#include <Adafruit_RGBLCDShield.h>
#include <SD.h>

// How many filenames we will be able to store
#define MAX_FILES 100

extern Adafruit_RGBLCDShield lcd;
#endif
