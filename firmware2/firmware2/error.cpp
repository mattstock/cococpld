#include <avr/io.h>
#include <Arduino.h>
#include "firmware2.h"
#include "error.h"

const char menu[][16] = {
	"program",
	"verify",
	"erase",
	"fdc"
};

const int menuCount = 4;
const char clearMenu[] = "                ";

const char dirfail[] = "Dir failed";
const char cardfail[] = "Card failed";
const char nofiles[] = "No Files";
const char openfail[] = "Open failed";
const char verify[] = "Verify ";
const char erasing[] = "Erasing ";
const char complete[] = "complete";
const char prog[] = "Prog ";
const char errfail[] = "Error";

void displayMenu(int i) {
	lcd.setCursor(0,0);
	lcd.print(clearMenu);
	lcd.setCursor(0,0);
	lcd.print(menu[i]);
}

void displayMsg(int i) {
	char *ptr;
		
	switch (i) {
		case DIR_FAILED:
			ptr = (char *)dirfail;
			break;
		case CARD_FAILED:
			ptr = (char *)cardfail;
			break;
		case NO_FILES:
			ptr = (char *)nofiles;
			break;
		case OPEN_FAILED:
			ptr = (char *)openfail;
			break;
		case VERIFY:
			ptr = (char *)verify;
			break;
		case ERASE:
			ptr = (char *)erasing;
			break;
		case COMPLETE:
			ptr = (char *)complete;
			break;
		case PROGRAMMING:
			ptr = (char *)prog;
			break;
		default:
			ptr = (char *)errfail;
			break;
			
	}
	lcd.print(ptr);	
}
