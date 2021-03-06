#ifndef _ROM_H
#define _ROM_H

#include <SD.h>

void eraseFlash();
void unlockFlash();
int programROM(File file);
void viewROM();
int verifyROM(File file);
void programByte(uint16_t addr, uint8_t data);
void printRegisters();


#endif
