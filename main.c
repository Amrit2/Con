/*
 * A3a.c
 *
 * Created: 21/09/2017 3:37:02 PM
 * Author : ktp5126
 */ 

#define F_CPU 8000000UL
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
#define checkTX     0x00
#define SET_PORTC   0x0A
#define START_BYTE  0x53
#define STOP_BYTE   0xAA
#define TX_VALID 0x0F

//char led[8] = "00010001";
//int i = 0;
//int b = 7;
//char line0[20];
unsigned char data;
//int x = 0;

void setup(void);
void UARTSend(unsigned char data);
ISR (USART1_RX_vect);
volatile enum comms COMM_STATE;	// Communications state machine
volatile uart rxData;
volatile unsigned char dataStatus;



int main(void)
{
	setup();

    while (1) 
    {
		if (dataStatus)
        {
            dataStatus = 0;
            memcpy(&data, &rxData, sizeof(rxData));
            
            switch(data.INS)
            {
                case checkTX:
                    UARTSendByte(TX_VALID);
                    break;
                case read_PINA:
                    UARTSendByte(PINA);
                    break;
                case SET_PORTC:
                    PORTC = data.LSB;
                    UARTSendByte(data.INS);
                    break;
                    
                default:
                    UARTSendByte(0xFF);	// C# program expects something back.
                    break;
            }
        }
		//UARTSend(PINA);
		
    }
}

void setup(void)
{
	DDRA = 0x00;		//set PORTA for input
	DDRC = 0xFF;		// set PORTC for output
	DDRE = 0b00000011;	//PORTE is required to be setup for
	PORTE = 0x00;		//PORTC - PORTA lab board interface.
    
    UCSR1A = 0x00;
	UBRR1L = 12;		//38.4k baud rate
	UCSR1B = 0b10011000; //RX interrupts , RX and TX enabled
	UCSR1C = 0b00000110; //async, no parity, 8 data bits, 1 stop bit
	sei();
	SLCDInit();         				// Initialize the LCD.
	SLCDDisplayOn();    				// Switched On the LCD.
	SLCDClearScreen();				// clear the LCD
}

ISR (USART1_RX_vect)
{
    char data;
    data = UDR1;
    
    // i'm thinking all this is built in due to the capitals, if not then -_-
    switch(COMM_STATE)
    {
            // Start Byte
        case COMM_START:
            if(data == START_BYTE)
            {
                COMM_STATE = COMM_INS;	// Change state to INS
            }
            break;
            // Instruction Byte
        case COMM_INS:
            if(data >= checkTX)	// Change state to STOP
            {
                rxData.INS = data;
                COMM_STATE = COMM_STOP;
            }
            else if(data >= SET_PORTC)	// Change state to LSB
            {
                rxData.INS = data;
                COMM_STATE = COMM_LSB;
            }
            else	// Invalid INS. Back to START
            {
                COMM_STATE = COMM_START;
            }
            break;
            // Data (LSB) Byte
        case COMM_LSB:
            rxData.LSB = data;
            COMM_STATE = COMM_MSB;
            break;
            // Data (MSB) Byte
        case COMM_MSB:
            rxData.MSB = data;
            COMM_STATE = COMM_STOP;
            break;
            // Stop Byte
        case COMM_STOP:
            // If message correctly terminated, set data ready flag
            if(data == STOP_BYTE)
            {
                dataStatus = 1;	// Flag: Data Ready
            }
            // No matter what, go back to START
            COMM_STATE = COMM_START;
            break;
    }
	
}

void UARTSend(unsigned char data)
{
	while (!TX_EMPTY);
	UDR1 = data;
	while (!TX_COMPLETE);
	UCSR1A |= (1<<TXC1);
}



// NOTE: structures below goes in UART.h <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
enum comms {COMM_START, COMM_STOP, COMM_INS, COMM_MSB, COMM_LSB};
typedef struct
{
    unsigned char INS;	// Instruction byte
    unsigned char MSB;	// uint16_t - MSB
    unsigned char LSB;	// uint16_t - LSB
}uart;
