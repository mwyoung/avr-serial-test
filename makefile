SHELL		:= /bin/bash
SRC			:= serial_test
OBJ			:= $(SRC).o
MCU_TARGET	:= atmega328p
F_CPU		:= 16000000UL
CC			:= avr-gcc
OPTIMIZE	:= -O2
SRC_DIR		:= .
BUILD_DIR	:= build-$(MCU_TARGET)
LIBS		=

#look in subdirectories for source
#VPATH		=

override CFLAGS := -g -Wall $(OPTIMIZE) -mmcu=$(MCU_TARGET) -DF_CPU=$(F_CPU)
override LDFLAGS := -Wl,-Map,$(BUILD_DIR)/$(SRC).map

#float adds ~1.5kB to code
PRINTF_LIB_MIN = -Wl,-u,vprintf -lprintf_min
PRINTF_LIB_FLOAT = -Wl,-u,vfprintf -lprintf_flt
PRINTF_LIB = $(PRINTF_LIB_MIN)
MATH_LIB = -lm
LDFLAGS += $(PRINTF_LIB) $(MATH_LIB)

OBJCOPY		= avr-objcopy
OBJDUMP		= avr-objdump

.PHONY: all clean
all: $(SRC).elf lst text

%.hex: %.obj
	avr-objcopy -R .eeprom -O ihex $< $@

$(BUILD_DIR)/%.obj: $(OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

program: $(BUILD_DIR)/$(SRC).hex | $(BUILD_DIR)
	avrdude -p $(MCU_TARGET) -c usbasp -e -U flash:w:$(BUILD_DIR)/$(SRC).hex

compile: $(BUILD_DIR)/$(SRC).hex | $(BUILD_DIR)

SERIAL_PORT	= $(shell ls /dev/ttyUSB* | head -n 1)
COMM_PREF = .moserial.conf
serialcomm:
	sed -i 's,device='.*',device='"$(SERIAL_PORT)"',g' $(COMM_PREF)
	moserial --profile=$(COMM_PREF)

$(BUILD_DIR):
	-mkdir -p $(BUILD_DIR)

clean:
	-rm -f *.o *.hex *.obj *.d *.map $(BUILD_DIR)/*

#Help from: https://collectiveidea.com/blog/archives/2017/04/05/arduino-programming-in-vim
#and https://www.avrfreaks.net/comment/2732811#comment-2732811
AVR_LIB = /usr/lib/avr/include
AVR_LIB_IO = /$(AVR_LIB)/avr
AVR_TAG = tags.avr
TAG_FILE = .tags
FILE_TYPES = -regex ".*\.\(h\|c\|ino\|hpp\|cpp\|pde\)"
ctags:
	find $(AVR_LIB) $(FILE_TYPES) -a -not -name "io*.h" -print > $(AVR_TAG)
	echo "$(AVR_LIB_IO)/io.h" >> $(AVR_TAG)
	echo "$(AVR_LIB_IO)/iom328p.h" >> $(AVR_TAG)
	find $(shell pwd) $(FILE_TYPES) -print >> $(AVR_TAG)
	ctags -L $(AVR_TAG) -f $(TAG_FILE)
	rm -f tags.*
