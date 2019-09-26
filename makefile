SHELL		:= /bin/bash
PRG			:= blink
OBJ			:= $(PRG).o
MCU_TARGET	:= atmega328p
F_CPU		:= 16000000UL
CC			:= avr-gcc
OPTIMIZE	:= -O2
BUILD_DIR	:= build-$(MCU_TARGET)

override CFLAGS := -g -Wall $(OPTIMIZE) -mmcu=$(MCU_TARGET) -DF_CPU=$(F_CPU)

PRINTF_LIB_MIN = -Wl,-u,vprintf -lprintf_min
PRINTF_LIB_FLOAT = -Wl,-u,vfprintf -lprintf_flt
PRINTF_LIB = $(PRINTF_LIB_FLOAT)
MATH_LIB = -lm
LDFLAGS += $(PRINTF_LIB) $(MATH_LIB)
#override LDFLAGS := -Wl,-Map,$(PRG).map

all: $(PRJ).hex

clean:
	-rm -f *.o *.hex *.obj *.d

%.hex: %.obj
	avr-objcopy -R .eeprom -O ihex $< $@

%.obj: $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) $(LDFLAGS) -o $@

program: $(PRG).hex
	avrdude -p $(MCU_TARGET) -c usbasp -e -U flash:w:$(PRG).hex

compile: $(PRG).hex

SERIAL_PORT	= $(shell ls /dev/ttyUSB* | head -n 1)
COMM_PREF = sm.conf
serialcomm:
	sed -i 's,device='.*',device='"$(SERIAL_PORT)"',g' $(COMM_PREF)
	moserial --profile=$(COMM_PREF)
