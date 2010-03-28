#include <stdlib.h>

#include "uart.h"
#include "config.h"
#include "util.h"


uint16_t hextoui(uint8_t * str){
	uint8_t c;
	uint16_t ui=0;
	while(c = *str++){
		ui <<= 4;
		if(c<='9'){
			ui |= c-'0';	
		}else{
			ui |= c-('a'-10);	
		}
	}
	return ui;
}

void hexdump(unsigned char * addr, unsigned int size){
	unsigned char x=0, sbuf[3];
	
	while(size--){
		itoa(*addr++, sbuf, 16);
		if (sbuf[1] == 0) print("0");
		print(sbuf);
		print(" ");
		if(++x == 16){
			print("\r\n");
			x = 0;
		}
	}
}

void hexprint16(uint16_t i){
	uint8_t sbuf[5];
	itoa(i, sbuf, 16);
	
	if (sbuf[1] == 0){
		print("000");
	}else if (sbuf[2] == 0){
		print("00");	
	}else if (sbuf[3] == 0){
		print("0");	
	}	
	print(sbuf);
}

void hexprint8(uint8_t i){
	uint8_t sbuf[3];
	itoa(i, sbuf, 16);
	if (sbuf[1] == 0){
		print("0");
	}
	print(sbuf);
}

uint16_t gethex16(){
	uint8_t c, len;
	uint8_t buf[5];
	len=0;
	do{
		c = getc();
		if(((c>='0') && (c<='9'))||((c>='a') && (c<='f'))){
			putc(c);
			buf[len] = c;
			len++;
		}
	}while((len<4) && (c != '\r'));
	buf[len] = 0;
	return hextoui(buf);
}
