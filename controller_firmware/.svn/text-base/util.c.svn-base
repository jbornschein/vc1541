
#include <stdlib.h>
#include "uart.h"

void hexdump(unsigned char * addr, unsigned char size){
	unsigned char x=0, sbuf[3];
	
	while(size--){
		itoa(*addr++, sbuf, 16);
		if (sbuf[1] == 0) uart_putstr("0");
		uart_putstr(sbuf);
		uart_putstr(" ");
		if(++x == 16){
			uart_putstr("\r\n");
			x = 0;
		}
	}
}


/*
void dump(){
	print("Can Dump:\n");
	while(1){
		cm = can_get_nb();
		if(cm){
			print("Received Message:\n");
			hexdump((void*)cm, (cm->dlc)+5);
			print("\n");
		}
	
	}	
}

*/
