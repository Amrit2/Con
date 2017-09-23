/*
 * A3a.c
 *
 * Created: 21/09/2017 3:37:02 PM
 * Author : ktp5126
 */ 

#include <avr/io.h>
#include <LabBoard.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <avr/interrupt.h>

#define RX_FULL		(UCSR1A & (1 << RXC1))
#define TX_EMPTY	(UCSR1A & (1 << UDRE1))
#define TX_COMPLETE	(UCSR1A & (1 << TXC1))
#define readPINA	0x01

char led[8] = "00010001";
int i = 0;
int b = 7;
char line0[20];
unsigned char data;
int x = 0;

void setup(void);
void UARTSend(unsigned char data);
ISR (USART1_RX_vect);

int main(void)
{
	setup();

    while (1) 
    {
		
		UARTSend(PINA);
		/*if (RX_FULL)
		{
			
				
				SLCDSetCursorPosition(0,0);
				sprintf(line0, UDR1);
				SLCDWriteString(line0);
				PORTC = UDR1;	
		}*/
    }
}

void setup(void)
{
	DDRA = 0x00;		//set PORTA for input
	DDRC = 0xFF;		// set PORTC for output
	DDRE = 0b00000011;	//PORTE is required to be setup for
	PORTE = 0x00;		//PORTC - PORTA lab board interface.
	UBRR1L = 12;		//38.4k baud rate
	UCSR1B = 0b10011000; //interrupts off, RX and TX enabled
	UCSR1C = 0b00000110; //async, no parity, 8 data bits
	sei();
	SLCDInit();         				// Initialize the LCD.
	SLCDDisplayOn();    				// Switched On the LCD.
	SLCDClearScreen();				// clear the LCD
}

ISR (USART1_RX_vect)
{
	if (UDR1 == 0x53)
	{
		data = UDR1; // store the received values into buffer while still receiving GPS input
	PORTC = data;
	}
	
}

void UARTSend(unsigned char data)
{
	while (!TX_EMPTY);
	UDR1 = data;
	while (!TX_COMPLETE);
	UCSR1A |= (1<<TXC1);
}

