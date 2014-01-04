#include <Arduino.h>
#include <SD.h>
#include "busio.h"
#include "rom.h"
#include "debug.h"
#include "firmware2.h"
#include "fdc.h"

char cmd[30];

void readLine() {
  int index = 0;
  while (1) {
    if (Serial.available() > 0) {
      cmd[index] = Serial.read();
      cmd[index+1] = '\0';
      Serial.write(&(cmd[index]));
      if (cmd[index] == 0x0b) {
	index = 0;
      } else if (cmd[index] == '\b') {
        if (index != 0)
	  index--;
      } else if (cmd[index] == '\r') {
	Serial.println("");
	cmd[index] = '\0';
	index = 0;
	return;
      } else
	index++;
    } 
  }
}

char a2h(char c) {
  if (c < 'a')
    return c-48;
  else
    return c-97+10;
}

void debugCommand() {
  Serial.print("BEXKAT> ");
  readLine();
  switch (cmd[0]) {
  case 'r':
    Serial.println(readData(), HEX);
    break;
  case 'w':
    setData((a2h(cmd[1]) << 4) + a2h(cmd[2]));
    Serial.println("Data written");
    break;
  case 'd':
    if (cmd[1] == 'r') 
      programROM(SD.open(config[ROM]));
    else
      programROM(SD.open(config[DSKROM]));
    Serial.println("Flash programmed");
    break;
  case 'v':
    if (cmd[1] == 'r')
      verifyROM(SD.open(config[ROM]));
    else
      verifyROM(SD.open(config[DSKROM]));
    Serial.println("Flash verify");
    break;
  case 'f':
    Serial.println("Peripheral mode");
    controlPending = false;
    commandPending = false;
    attachInterrupt(0, loadConfig, FALLING);
    attachInterrupt(1, loadCommand, FALLING);
    fdc();
    break;
  case 'e':
    eraseFlash();
    Serial.println("FLASH erased");
    break;
  case 'i':
    controlPending = false;
    commandPending = false;
    attachInterrupt(0, loadConfig, FALLING);
    attachInterrupt(1, loadCommand, FALLING);
    Serial.println("interrupts enabled");
    break;
  case 'a':
    setAddress((a2h(cmd[1]) << 12) + (a2h(cmd[2]) << 8) +
	       (a2h(cmd[3]) << 4) + a2h(cmd[4]));
    Serial.println("Address set");
    break;
  }
}

void fault() {
  // error blinky
  while (1) {
    pinMode(13, OUTPUT);
    digitalWrite(13, HIGH);
    delay(1000);
    digitalWrite(13, LOW);
    delay(1000);
  }
}
