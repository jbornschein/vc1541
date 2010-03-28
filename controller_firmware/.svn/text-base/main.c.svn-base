#include "config.h"

#include <stdlib.h>
#include <stdint.h>
#include "util.h"
#include "uart.h"
#include "ks0108.h"
#include "ff.h"
#include <string.h>


uint16_t getword(){
	union{
		uint8_t b[2];
		uint16_t w;
	}u;
	
	u.b[0] = uart_getc();
	u.b[1] = uart_getc();
	return u.w;
}


FATFS fs;				/* File system object */
FIL fil;


int main(){
	uint8_t command, data;
	uint16_t address, size;
	WORD fsize;
	void (*fp) (void);
	
	FRESULT fresult;
	
	fp = (void (*) (void))0x200;
	
	uart_init();
	
	uart_putstr("Bootloader>\n\r");

	dispInit();
	
	dispPrint("* FPGA Floppy  *\nbooting...\n");
	
	if(SWITCH_I & 0x40){
		dispPrint("switch 6 on -\n");
		goto uartmode;
	}
	
	dispPrint("Initing MMC...\n");
	
	memset(&fs, 0, sizeof(FATFS)); 	/* Clear file system object */
	FatFs = &fs;					/* Assign it to the FatFs module */	
	
	fresult = f_open(&fil, "sys/firmware.bin", FA_READ|FA_OPEN_EXISTING);
	
	if(fresult){
		switch(fresult){
			case FR_NO_FILE:
			case FR_NO_PATH:
				dispPrint("sys/firmware.bin\nnot found.\n");
				break;
			case FR_NOT_READY:
				dispPrint("no MMC/SD card.\n");
				break;
			case FR_NO_FILESYSTEM:
				dispPrint("no FAT\nfilesystem.\n");
				break;
		}
		goto uartmode;
	}
	
	//goto uartmode;

	
	dispPrint("Loading\nfirmware...\n");
	
	f_read (&fil, (uint8_t*)0x200, 0xc000, &fsize);

	fp();
	
uartmode:
	
	dispPrint("Uart mode.");	
	
	while(1){
		command = uart_getc();
	
		switch (command){
			case 'u'://upload
				address = getword();
				size = getword();
				for(;size--;address++){
						data = uart_getc();
						outb(address, data);
				}
				break;
			case 'b'://binary download
				address = getword();
				size = getword();
				for(;size--;address++){
					data = *(uint8_t*)address;
					uart_putc(data);
				}
				break;
			case 'd'://dump
				address = getword();
				hexdump((uint8_t*)address, uart_getc());
				break;
			case 'j'://jump
				address = getword();
				hexdump((uint8_t *)&address, 2);
				fp = (void (*) (void))address;
				fp();
			case 'r'://ready
				uart_putstr("READY.\r\n");
				break;
		}
	}
		
}
