#ifndef FDC_H
#define FDC_H

#define MAGIC 0x7f00
#define DSKREG 0x7f40
#define FDCCMD 0x7f48
#define FDCSTAT 0x7f08
#define FDCTRK 0x7f49
#define FDCSEC 0x7f4a
#define FDCDAT 0x7f4b
#define TRACKSIZE 0x1900

void fdc();

#endif
