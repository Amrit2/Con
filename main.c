/*
 * Assignment 3 - MCU.c
 *
 * Created: 11/09/2017 3:37:02 PM
 * Author : Alvin Kumar & Amrit Kaur
 */ 

#include <avr/io.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <avr/interrupt.h>

//TX/RX defines
#define RX_FULL		(UCSR1A & (1 << RXC1))
#define TX_EMPTY	(UCSR1A & (1 << UDRE1))
#define TX_COMPLETE	(UCSR1A & (1 << TXC1))
#define READ_PINA	0x01
#define CHECK_TX    0x00
#define SET_PORTC   0x0A
//Switch State Defines
#define start		0
#define instruct	1
#define msb			2
#define lsb			3
#define stop		4


char START_BYTE = 0x53;
#define STOP_BYTE   0xAA
#define TX_VALID	0x0F



//Data variables for incoming data
unsigned char data;
unsigned char msbDATA;
unsigned char lsbDATA;
char state;

int flag = 0;

//Function prototypes
void setup(void);
ISR (USART1_RX_vect);

int main(void)
{
	setup();

    while (1) 
    {
		if(data == CHECK_TX)				//if instruction data from UART is to check transmission			
		{	
			UDR1 = TX_VALID;					//Uart O/P the yes TX was successful byte
		}
		else if (data == READ_PINA)				//if instruction data is to read PINA byte 
		{
			UDR1 = PINA;						//Uart O/P the PINA data 
		}
		else if (flag == 1)			//if instruction data is Set PORTC byte
		{
			PORTC = msbDATA;			//O/P the data that is saved in the msb and lsb data variables to PORTC
			flag = 0;
		}
    }
}

void setup(void)
{
	DDRA 	= 0x00;			//set PORTA for input
	DDRC	= 0xFF;			// set PORTC for output
	DDRE 	= 0b00000011;	//PORTE is required to be setup for
	PORTE 	= 0x00;			//PORTC - PORTA lab board interface.
	UBRR1L 	= 12;			//38.4k baud rate
	UCSR1B 	= 0b10011000;	//interrupts off, RX and TX enabled
	UCSR1C 	= 0b00000110;	//async, no parity, 8 data bits
	sei();					//interupts enabled.
	

}

ISR (USART1_RX_vect)
{
	data = UDR1;

	switch(state)
	{
		case start:						// Default state: Check if incoming data is required Start Byte
			if (data == START_BYTE)
				state = instruct;		//If so, move to instruction state
		break;
		case instruct:				//save the incoming byte to data variable
			if (data >= SET_PORTC)		//if the data is set portc instruction, switch state to MSB
			{
				state = msb;
			}
									
			else
				state = stop;
		break;
		case msb:
			msbDATA = data;				//save the next incoming byte to msbDATA variable, switch state to lsb save the next byte
			state = lsb;
		case  lsb:						//save the LSB byte, switch to stop state
			lsbDATA = data;
			flag = 1;
			state = stop;
		break;
		case stop:						//check if next byte is stop byte, if so return to start and await next RX
			if (data == STOP_BYTE)
				state = start;
		break;
		
	}
	
}
