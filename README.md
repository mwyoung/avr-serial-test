# serial\_test for AVR

This program is to test serial communication for AVR. It was tested on a Arduino Nano
clone (with a CH340) on linux and a USBASP programmer.

Note: using this method will erase the Arduino bootloader. To reinstall the bootloader use
the Arduino IDE with the programmer "USBASP" and Tools -> Burn Bootloader.

## Requirements:

<img align="right" height="400"
src="https://user-images.githubusercontent.com/10273995/65840436-fe0dc880-e2cd-11e9-9c16-e0c4f4990c73.jpg"/>

This example program uses an Arduino Nano, a USBASP v2.0, and a USB mini B cable (for
serial communication).  Also required (for Linux) is makefile, avr-gcc, avrdude, and
moserial.

The wiring is using the 6 pin port connected to the USBASP (recommended is a 10 pin to 6
pin connector), and the usb port connected to another USB on the computer.  It is also
possible to disconnect the 3.3V/5V jumper (and leave it connected to 1 pin). However, this
may need to be disconnected when using SPI.

To install, use the command `make program` to upload to the AVR board.

## Help From:
[Avrfreaks - abcminiuser](https://www.avrfreaks.net/forum/tut-soft-using-usart-serial-communications).
