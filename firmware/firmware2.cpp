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
#include <Adafruit_RGBLCDShield.h>
#include "firmware2.h"
#include "rom.h"
#include "fdc.h"
#include "busio.h"
#include "debug.h"

char *config[MAX_CONFIG];
//Adafruit_RGBLCDShield lcd = Adafruit_RGBLCDShield();

EthernetClient client;

void parseLine(char *line) {
  if (!strncmp("floppy0 ", line, 8)) {
    config[FLOPPY0] = (char *) malloc(13);
    strncpy(config[FLOPPY0], &(line[8]), 13);
  }
  if (!strncmp("floppy1 ", line, 8)) {
    config[FLOPPY1] = (char *) malloc(13);
    strncpy(config[FLOPPY1], &(line[8]), 13);
  }
  if (!strncmp("rom0 ", line, 5)) {
    config[ROM0] = (char *) malloc(13);
    strncpy(config[ROM0], &(line[5]), 13);
  }
  if (!strncmp("rom1 ", line, 5)) {
    config[ROM1] = (char *) malloc(13);
    strncpy(config[ROM1], &(line[5]), 13);
  }
  if (!strncmp("rom2 ", line, 5)) {
    config[ROM2] = (char *) malloc(13);
    strncpy(config[ROM2], &(line[5]), 13);
  }
  if (!strncmp("floppy-rom ", line, 11)) {
    config[ROM3] = (char *) malloc(13);
    strncpy(config[ROM3], &(line[11]),13);
  }
}

// Pull data from setup.txt if available
void loadSetup() {
  char line[30];
  uint8_t idx = 0;
  
  if (client.connect("www.bexkat.com", 80)) {
    Serial.println("connected.");
    client.println("GET /coco/setup.txt HTTP/1.1");
    client.println("Host: www.bexkat.com");
    client.println("Connection: close");
    client.println();
  } else {
    Serial.println("failed to pull setup");
    return;
  }
  
  for (int i=0; i < MAX_CONFIG; i++)
    config[i] = NULL;
  
  Serial.println("Loading config file");
  
  while (client.connected()) {
    if (client.available()) {
      line[idx++] = client.read();
      if (idx == 30) {
	Serial.print("Truncating line.");
	line[idx-1] = '\n';
      }
      if (line[idx-1] == '\r') {
	idx--;
	continue;
      }
      if (line[idx-1] == '\n') {
	line[idx-1] = '\0';
	Serial.print("Parsing = |");
	Serial.print(line);
	Serial.println("|");
	parseLine(line);
	idx = 0;
      }
    }
  }
}

void setup() {
  // Serial port for debugging output
  Serial.begin(115200);

  // Set defaults for bus enable banks
  pinMode(BANK0_ENABLE_PIN, OUTPUT);
  pinMode(BANK1_ENABLE_PIN, OUTPUT);
  pinMode(BANK2_ENABLE_PIN, OUTPUT);
  pinMode(BANK3_ENABLE_PIN, OUTPUT);
  digitalWrite(BANK0_ENABLE_PIN, LOW);
  digitalWrite(BANK1_ENABLE_PIN, HIGH); // need to tristate MISO
  digitalWrite(BANK2_ENABLE_PIN, LOW);
  digitalWrite(BANK3_ENABLE_PIN, LOW);

  // Status LED on breakout board
  pinMode(LED_PIN, OUTPUT);

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
  pinMode(CMDETH_PIN, INPUT);

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
    //fault();
  }
  
  byte mac[] = { 0xaa, 0xbb, 0xcc, 0x00, 0x01, 0xed };
  if (Ethernet.begin(mac) == 0) {
    Serial.println("ethernet DHCP failure.");
  }

  loadSetup();

  //  uint8_t b = lcd.readButtons();
  //  if (b & BUTTON_SELECT) { // Hold select during reset will go into test mode
    // Go into the loop for the test mode
  //  Serial.println("Test mode");
  //  } else {
    Serial.println("Standard mode");
    setBank(0);
    programROM(SD.open(config[ROM0]));
    setBank(1);
    programROM(SD.open(config[ROM1]));
    setBank(2);
    programROM(SD.open(config[ROM2]));
    setBank(3);
    programROM(SD.open(config[ROM3]));
    controlPending = false;
    commandPending = false;
    attachInterrupt(0, loadConfig, FALLING);
    attachInterrupt(1, loadCommand, FALLING);
    fdc();
    //   }*/
}

extern void arduinomain(void);

void loop() {
  debugCommand();
}

int main(void) {
	arduinomain();
}
