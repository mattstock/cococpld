CC=avr-gcc
CXX=avr-g++
AR=avr-ar
OBJCOPY=avr-objcopy
OBJDUMP=avr-objdump
PROGRAMMER=jtag3
PORT=usb
MCU_TARGET=atmega2560 
AVRDUDE_TARGET=m2560
OPTIMIZE=-Os
DEFS=-DARDUINO=105
LIBS=-lm
HZ=16000000UL

OBJS=CDC.o HardwareSerial.o HID.o IPAddress.o main.o new.o Print.o Stream.o Tone.o USBCore.o WMath.o WString.o WInterrupts.o wiring.o wiring_pulse.o wiring_shift.o wiring_digital.o wiring_analog.o

OUT_DIR=output
OUT_OBJS=$(addprefix $(OUT_DIR)/,$(OBJS))

override CFLAGS        = -g -I. -DF_CPU=$(HZ) -Wall $(OPTIMIZE) -mmcu=$(MCU_TARGET) $(DEFS)
override CXXFLAGS	= $(CFLAGS)
override LDFLAGS       = -Wl,-Map,$(OUT_DIR)/$(PRG).map

all: $(OUT_DIR)/core.a

$(OUT_DIR)/core.a: $(OUT_OBJS)
	$(AR) rcs $@ $^

$(OUT_DIR)/%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OUT_DIR)/%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OUT_DIR)/*.o $(OUT_DIR)/core.a
