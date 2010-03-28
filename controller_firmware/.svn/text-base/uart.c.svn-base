
#include "util.h"
#include "uart.h"
#include "config.h"

#define BAUDVALUE ((F_CPU/BAUDRATE)-6)


void uart_init(){
		REG_UART_BAUD = BAUDVALUE;
}

uint8_t uart_getc(){
	//wait for Data available from UART
	while (! (REG_UART_FLAG & BIT_DATA_AVAIL));	
	return REG_UART_DATA;	
}

void uart_putc(uint8_t byte){
	//wait until uart is finished
	while (! (REG_UART_FLAG & BIT_TRANSMIT));	
	REG_UART_DATA = byte;
}

void uart_putstr(uint8_t * str){
	uint8_t c;
	while((c = *str++)){
		uart_putc(c);	
	}
}
