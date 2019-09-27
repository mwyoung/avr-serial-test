#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>

#define F_CPU 16000000UL
//serial comm tutorial: https://www.avrfreaks.net/forum/tut-soft-using-usart-serial-communications
//can leave usbasp plugged in, just remove jumper to 5V (and don't connect it to 3.3V)
#define USART_BAUDRATE 9600
#define BAUD_PRESCALE (((F_CPU / (USART_BAUDRATE * 16UL))) - 1)
#define SERIAL_DEBUG
//note: serial sending could send extra bits as terminating chars
//#define SERIAL_ECO_DEBUG //if commented has 1 second delay
//#define PRINTF_LIB_FLOAT //adds ~1.5kB to code

int uart_putchar(char c, FILE *stream){
    while ((UCSR0A & (1<<UDRE0))==0) {};
    UDR0 = c;
    return 0;
}

FILE uart_str = FDEV_SETUP_STREAM(uart_putchar, NULL, _FDEV_SETUP_WRITE);

int main(void){
#ifndef SERIAL_ECO_DEBUG
    uint8_t i;
#endif
    uint16_t count = 0;
    DDRB = (1<<PB5); //set PB5 output for led

#ifdef SERIAL_DEBUG
    char rcvByte;
    UCSR0B |= (1<<RXEN0)|(1<<TXEN0);        //turn on tx/rx
    UCSR0C |= (1<<UCSZ00)|(1<<UCSZ01);      //8-bit chars
    UBRR0H = (BAUD_PRESCALE >> 8);          //load upper bits for baud rate
    UBRR0L = BAUD_PRESCALE;                 //load lower bits
    stdout = &uart_str;
#endif

#ifdef PRINTF_LIB_FLOAT
    printf("Printing now works, can output floats %f\n", (double)22/7);
#else
    printf("Printing now work\n");
#endif

    while(1){
#ifdef SERIAL_DEBUG
        printf("Loop:%d\n", count);
#endif
        count++;
        PORTB ^= (1<<PB5); //flip LED

#ifdef SERIAL_ECO_DEBUG
        while ((UCSR0A & (1<<RXC0))==0) {}; //wait for data
        rcvByte = UDR0;                     //put received byte in variable
        while ((UCSR0A & (1<<UDRE0))==0) {}; //wait until UDR is empty
        UDR0 = rcvByte;                     //send data back to computer
#else
        for(i=0;i<10;i++){_delay_ms(100);} //wait 1 second
#endif
    }
}

