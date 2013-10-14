CC=avr-gcc
CXX=avr-g++
AR=avr-ar
MCU_TARGET=atmega2560 
OPTIMIZE=-Os
DEFS=-DARDUINO=105
HZ=16000000UL

OBJS=CDC.o HardwareSerial.o HID.o IPAddress.o main.o new.o Print.o Stream.o Tone.o USBCore.o WMath.o WString.o WInterrupts.o wiring.o wiring_pulse.o wiring_shift.o wiring_digital.o wiring_analog.o

override CFLAGS        = -g -I. -DF_CPU=$(HZ) -Wall $(OPTIMIZE) -mmcu=$(MCU_TARGET) $(DEFS)
override CXXFLAGS	= $(CFLAGS)

all: libarduino.a

libarduino.a: $(OBJS)
	$(AR) rcs $@ $^

$(OUT_DIR)/%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OUT_DIR)/%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o arduino.a
