#ifndef _FIRMWARE2_H
#define _FIRMWARE2_H

#include <SPI.h>
#include <SD.h>

#define FLOPPY0 0
#define FLOPPY1 1
#define ROM0    2
#define ROM1    3
#define ROM2    4
#define ROM3    5
#define MAX_CONFIG 6

extern char *config[];

extern void loadSetup();

#endif
