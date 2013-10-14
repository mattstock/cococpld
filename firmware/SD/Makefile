CC=avr-gcc
CXX=avr-g++
AR=avr-ar
MCU_TARGET=atmega2560 
OPTIMIZE=-Os
DEFS=-DARDUINO=105
HZ=16000000UL

OBJS=utility/Sd2Card.o utility/SdFile.o utility/SdVolume.o File.o SD.o

override CFLAGS        = -g -I../arduino-core -I. -Iutility -DF_CPU=$(HZ) -Wall $(OPTIMIZE) -mmcu=$(MCU_TARGET) $(DEFS)
override CXXFLAGS	= $(CFLAGS)

all: libsd.a

libsd.a: $(OBJS)
	$(AR) rcs $@ $^

$(OUT_DIR)/%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OUT_DIR)/%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o *.a
