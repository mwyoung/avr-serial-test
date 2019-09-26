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
#define SERIAL_DEBUG true
uint16_t count = 0;

int uart_putchar(char c, FILE *stream){
    while ((UCSR0A & (1<<UDRE0))==0) {};
    UDR0 = c;
    return 0;
}

FILE uart_str = FDEV_SETUP_STREAM(uart_putchar, NULL, _FDEV_SETUP_WRITE);

int main(){
    //setup
    DDRB = (1<<PB5); //set PB5 output

#ifdef SERIAL_DEBUG
    UCSR0B |= (1<<RXEN0)|(1<<TXEN0); //turn on tx/rx
    UCSR0C |= (1<<UCSZ00)|(1<<UCSZ01); //8-bit chars
    UBRR0H = (BAUD_PRESCALE >> 8); //load upper bits for baud rate
    UBRR0L = BAUD_PRESCALE; //load lower bits
#endif
    stdout = &uart_str;

    while(1){
        printf("%s:%d %f\n", "hello", count, (double)22/7);
        count++;
        PORTB |= (1<<PB5); //turn on LED
        _delay_ms(1000);

        PORTB &= ~(1<<PB5);
        _delay_ms(1000);
    }
}

//while ((UCSR0A & (1<<RXC0))==0) {};
//RcvByte = UDR0; //tx
//while ((UCSR0A & (1<<UDRE0))==0) {};
//UDR0 = RcvByte; //rx
