SHELL		:= /bin/bash
PRG			:= serial_test
OBJ			:= $(PRG).o
MCU_TARGET	:= atmega328p
F_CPU		:= 16000000UL
OPTIMIZE	:= -O2
PRG_DIR		:= .
BUILD_DIR	:= build-$(MCU_TARGET)
LIBS		=

#Source: https://www.nongnu.org/avr-libc/user-manual/group__demo__project.html
#look in subdirectories for source
#VPATH		=
override CFLAGS := -g -Wall $(OPTIMIZE) -mmcu=$(MCU_TARGET) -DF_CPU=$(F_CPU)
override LDFLAGS := -Wl,-Map,$(BUILD_DIR)/$(PRG).map

#float adds ~1.5kB to code
PRINTF_LIB_MIN = -Wl,-u,vprintf -lprintf_min
PRINTF_LIB_FLOAT = -Wl,-u,vfprintf -lprintf_flt
PRINTF_LIB = $(PRINTF_LIB_MIN)
MATH_LIB = -lm
LDFLAGS += $(PRINTF_LIB) $(MATH_LIB)

CC			= avr-gcc
OBJCOPY		= avr-objcopy
OBJDUMP		= avr-objdump
OBJSIZE		= avr-size

all: $(BUILD_DIR)/$(PRG).elf lst text eeprom

program: $(BUILD_DIR)/$(PRG).hex size
	avrdude -p $(MCU_TARGET) -c usbasp -e -U flash:w:$(BUILD_DIR)/$(PRG).hex

compile: $(BUILD_DIR)/$(PRG).hex size

size:
	$(OBJSIZE) -C --mcu=$(MCU_TARGET) $(BUILD_DIR)/$(PRG).elf

# $@ = filename of target, $< name of 1st prereq; $? name prereq newer, $^ all prereq
$(BUILD_DIR)/$(PRG).elf: $(OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)
	-mv *.o $(BUILD_DIR)/

clean:
	-rm -rf $(BUILD_DIR)/*.{o,elf,lst,map,srec,bin,hex,d}

# show headers + source + disasmb + line numbers + demangle
asm: $(BUILD_DIR)/$(PRG).elf
	$(OBJDUMP) -hSdlC $(BUILD_DIR)/$(PRG).elf > $(BUILD_DIR)/$(PRG).lst

lst: $(BUILD_DIR)/$(PRG).lst

$(BUILD_DIR)/%.lst: $(BUILD_DIR)/%.elf
	$(OBJDUMP) -h -S $< > $(BUILD_DIR)/$@

# Rules for building the .text rom images
text: hex bin srec

hex:  $(BUILD_DIR)/$(PRG).hex
bin:  $(BUILD_DIR)/$(PRG).bin
srec: $(BUILD_DIR)/$(PRG).srec

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@

$(BUILD_DIR)/%.srec: $(BUILD_DIR)/%.elf
	$(OBJCOPY) -j .text -j .data -O srec $< $@

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf
	$(OBJCOPY) -j .text -j .data -O binary $< $@

# ======================= Other functions ===========================

SERIAL_PORT	= $(shell ls /dev/ttyUSB* | head -n 1)
COMM_PREF = .moserial.conf
serialcomm:
	sed -i 's,device='.*',device='"$(SERIAL_PORT)"',g' $(COMM_PREF)
	moserial --profile=$(COMM_PREF)

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
