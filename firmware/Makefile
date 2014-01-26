CC=avr-gcc
CXX=avr-g++
OBJCOPY=avr-objcopy
OBJDUMP=avr-objdump
#PROGRAMMER=jtag3isp
PROGRAMMER=jtag3
#PROGRAMMER=avrisp2
PORT=usb
MCU_TARGET=atmega2560 
AVRDUDE_TARGET=m2560
SERIAL=/dev/ttyACM0
BAUD=115200
OPTIMIZE=-Os
DEFS=-DARDUINO=105
LIBS=-lm -lethernet -larduino -lsd -lspi -llcd -lwire
HZ=16000000UL

PRG=firmware
OBJS=firmware2.o rom.o fdc.o CocoImage.o CocoDisk.o busio.o debug.o

OUT_DIR=output
OUT_OBJS=$(addprefix $(OUT_DIR)/,$(OBJS))

override CFLAGS        = -g -Iarduino-core -ISPI -ISD -IEthernet -ILCD -IWire -DF_CPU=$(HZ) -Wall $(OPTIMIZE) -mmcu=$(MCU_TARGET) $(DEFS)
override CXXFLAGS	= $(CFLAGS) -std=c++11
override LDFLAGS       = -Wl,-Map,$(OUT_DIR)/$(PRG).map -Larduino-core -LSPI -LSD -LLCD -LEthernet -LWire

all: $(OUT_DIR)/$(PRG).elf lst text

$(OUT_DIR)/$(PRG).elf: arduino-core/libarduino.a Ethernet/libethernet.a Wire/libwire.a SPI/libspi.a SD/libsd.a LCD/liblcd.a $(OUT_DIR) $(OUT_OBJS)
	$(CXX) $(CFLAGS) $(LDFLAGS) -o $@ $(OUT_OBJS) $(LIBS)

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

arduino-core/libarduino.a:
	cd arduino-core; make

SPI/libspi.a:
	cd SPI; make

Ethernet/libethernet.a:
	cd Ethernet; make

SD/libsd.a:
	cd SD; make

LCD/liblcd.a:
	cd LCD; make

Wire/libwire.a:
	cd Wire; make

$(OUT_DIR)/%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OUT_DIR)/%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	cd arduino-core; make clean
	cd SPI; make clean
	cd SD; make clean
	cd Ethernet; make clean
	cd LCD; make clean
	cd Wire; make clean
	cd arduino-core; make clean
	rm -f $(OUT_DIR)/*.o $(OUT_DIR)/$(PRG).elf *.bak $(OUT_DIR)/*.hex
	rm -f $(OUT_DIR)/*.lst $(OUT_DIR)/*.map
	rmdir $(OUT_DIR)

lst:  $(OUT_DIR)/$(PRG).lst

$(OUT_DIR)/%.lst: $(OUT_DIR)/%.elf
	$(OBJDUMP) -h -S $< > $@

# Rules for building the .text rom images

text: hex

hex:  $(OUT_DIR)/$(PRG).hex

$(OUT_DIR)/%.hex: $(OUT_DIR)/%.elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@

serial:
	stty -F $(SERIAL) $(BAUD) igncr

# command to program chip (invoked by running "make install")
install:  $(OUT_DIR)/$(PRG).hex
	avrdude -p $(AVRDUDE_TARGET) -c $(PROGRAMMER) -B 1 -P $(PORT) -v  \
         -U flash:w:$(OUT_DIR)/$(PRG).hex 

