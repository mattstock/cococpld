#ifndef ERROR_H
#define ERROR_H

#define DIR_FAILED 0
#define CARD_FAILED 1
#define NO_FILES 2
#define OPEN_FAILED 3
#define VERIFY 4
#define ERASE 5
#define COMPLETE 6
#define PROGRAMMING 7

extern const char errorMsg[][17];

#endif