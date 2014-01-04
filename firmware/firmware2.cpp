/*
 * firmware2.cpp
 *
 * Created: 4/20/2013 1:51:38 PM
 *  Author: stock
 */ 


#include <avr/io.h>
#include <avr/interrupt.h> 
#include <Arduino.h>
#include <Ethernet.h>
#include "firmware2.h"
#include "rom.h"
#include "fdc.h"
#include "busio.h"
#include "debug.h"

char *config[MAX_CONFIG];

void parseLine(char *line) {
	if (!strncmp("floppy0 ", line, 8)) {
		config[FLOPPY0] = (char *) malloc(13);
		strncpy(config[FLOPPY0], &(line[8]), 13);
	}
	if (!strncmp("floppy1 ", line, 8)) {
		config[FLOPPY1] = (char *) malloc(13);
		strncpy(config[FLOPPY1], &(line[8]), 13);
	}
	if (!strncmp("rom ", line, 4)) {
		config[ROM] = (char *) malloc(13);
		strncpy(config[ROM], &(line[4]), 13);
	}
	if (!strncmp("floppy-rom ", line, 11)) {
		config[DSKROM] = (char *) malloc(13);
		strncpy(config[DSKROM], &(line[11]),13);
	}
}

// Pull data from setup.txt if available
void loadSetup() {
	File f = SD.open("setup.txt");
	char line[30];
	uint8_t idx = 0;
	
	if (!f)
	  return;

	for (int i=0; i < MAX_CONFIG; i++)
		config[i] = NULL;

	Serial.println("Loading config file");
	
	while (f.available()) {
		line[idx++] = f.read();
		if (line[idx-1] == '\r') {
			idx--;
			continue;
		}
		if (line[idx-1] == '\n') {
			line[idx-1] = '\0';
#ifdef DEBUG
			Serial.print("Parsing = |");
			Serial.print(line);
			Serial.println("|");
#endif
			parseLine(line);
			idx = 0;
		}
	}
	f.close();
}

void setup() {
  // Serial port for debugging output
  Serial.begin(115200);
  
  // SPI used for microSD and WizNet (if plugged in)
  SPI.begin();
  SPI.setClockDivider(SPI_CLOCK_DIV4);
  SPI.setDataMode(SPI_MODE0);
  
  // To signal we have something for the Coco
  pinMode(COCOSELECT_PIN, OUTPUT);
  digitalWrite(COCOSELECT_PIN, HIGH);

  // Configure these as interrupts eventually
  pinMode(CMDINT_PIN, INPUT);
  pinMode(CFGINT_PIN, INPUT);
  
  // Default SS pin - set to known state
  pinMode(USBSELECT_PIN, OUTPUT);
  digitalWrite(USBSELECT_PIN, HIGH);
  
  // For Wiznet module SPI select
  pinMode(ETHSELECT_PIN, OUTPUT);
  digitalWrite(ETHSELECT_PIN, HIGH);
  
  // microSD SPI select
  pinMode(SDSELECT_PIN, OUTPUT);
  digitalWrite(SDSELECT_PIN, HIGH);
  
  Serial.print("Ram: ");
  Serial.println(FreeRam());
  
  // sdcard setup
  if (!SD.begin(SDSELECT_PIN)) {
    Serial.println("microSD failed");
    fault();
  }
  
  loadSetup();
  
  if (true) {   // !(PINE & _BV(PE6))) {
    // Go into the loop for the test mode
    Serial.println("Test mode");
  } else {
    Serial.println("Peripheral mode");
    controlPending = false;
    commandPending = false;
    attachInterrupt(0, loadConfig, FALLING);
    attachInterrupt(1, loadCommand, FALLING);
    fdc();
  }
}

extern void arduinomain(void);

void loop() {
  debugCommand();
}

int main(void) {
	arduinomain();
}
