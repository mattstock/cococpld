#ifndef _FIRMWARE2_H
#define _FIRMWARE2_H

#include <SPI.h>
#include <SD.h>

#define FLOPPY0 0
#define FLOPPY1 1
#define DSKROM  2
#define ROM     3
#define MAC     4

extern char *config[];

#endif
