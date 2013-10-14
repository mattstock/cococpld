CC=avr-gcc
CXX=avr-g++
OBJCOPY=avr-objcopy
OBJDUMP=avr-objdump
PROGRAMMER=jtag3
PORT=usb
MCU_TARGET=atmega2560 
AVRDUDE_TARGET=m2560
OPTIMIZE=
DEFS=-DARDUINO=105
LIBS=-lm
HZ=16000000UL

PRG=firmware
OBJS=firmware2.o rom.o fdc.o CocoImage.o CocoDisk.o busio.o

OUT_DIR=output
OUT_OBJS=$(addprefix $(OUT_DIR)/,$(OBJS))

override CFLAGS        = -g -Iarduino-core -ISPI -ISD -IEthernet -DF_CPU=$(HZ) -Wall $(OPTIMIZE) -mmcu=$(MCU_TARGET) $(DEFS)
override CXXFLAGS	= $(CFLAGS)
override LDFLAGS       = -Wl,-Map,$(OUT_DIR)/$(PRG).map

all: $(OUT_DIR)/$(PRG).elf lst text

$(OUT_DIR)/$(PRG).elf: arduino-core/output/core.a $(OUT_OBJS)
	$(CXX) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

arduino-core/output/core.a:
	cd arduino-core; make

$(OUT_DIR)/%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<
	
$(OUT_DIR)/%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	cd arduino-core; make clean
	rm -f $(OUT_DIR)/*.o $(OUT_DIR)/$(PRG).elf *.bak $(OUT_DIR)/*.hex
	rm -f $(OUT_DIR)/*.lst $(OUT_DIR)/*.map

lst:  $(OUT_DIR)/$(PRG).lst

$(OUT_DIR)/%.lst: $(OUT_DIR)/%.elf
	$(OBJDUMP) -h -S $< > $@

# Rules for building the .text rom images

text: hex

hex:  $(OUT_DIR)/$(PRG).hex

$(OUT_DIR)/%.hex: $(OUT_DIR)/%.elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@

# command to program chip (invoked by running "make install")
install:  $(OUT_DIR)/$(PRG).hex
	avrdude -p $(AVRDUDE_TARGET) -c $(PROGRAMMER) -P $(PORT) -v  \
         -U flash:w:$(OUT_DIR)/$(PRG).hex 

