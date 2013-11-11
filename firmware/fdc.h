#ifndef FDC_H
#define FDC_H

#define MAGIC 0xff50
#define DSKREG 0xff40
#define FDCCMD 0xff48
#define FDCSTAT 0xff51 // only from AVR view!
#define FDCTRK 0xff49
#define FDCSEC 0xff4a
#define FDCDAT 0xff4b
#define TRACKSIZE 0x1900

void fdc();

#endif
