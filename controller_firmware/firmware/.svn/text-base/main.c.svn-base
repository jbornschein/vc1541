#include "config.h"

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "util.h"
#include "uart.h"

#include "vdisk.h"
#include "monitor.h"

#include "diskio.h"
#include "ff.h"

#include "ks0108.h"

int getword(){
	union{
		uint8_t b[2];
		uint16_t w;
	}u;
	
	u.b[1] = uart_getc();
	u.b[0] = uart_getc();
	return u.w;
}

void track_stepper(){
	uint8_t sbuf[6];
	uint8_t new, old;
	uint8_t track = 18;
	old = 0;
	while(1){
		new = PAR_I_A0;
		if(new != old){
			
			itoa(PAR_I_A1, sbuf, 10);
			uart_putstr(sbuf);
			
			print("\t");
			
			itoa(new, sbuf, 10);
			uart_putstr(sbuf);
			
			
			uart_putstr("\r\n");
			old = new;
			
		}
	}
}



uint8_t spi_data(uint8_t dat){
	print("sending ");
	hexprint8(dat);
	SPI_DATA = dat;
	print (" received ");
	while(SPI_CTRL & 0x01);
	hexprint8(SPI_DATA);
	print("\r\n");
	return SPI_DATA;
}


DWORD get_fattime(void){
	return 0;	
	
}


FATFS fs;				/* File system object */
DIR dir;
FILINFO filinfo;
static FIL fil;


void handle_uart(){
	uint8_t command;
	uint16_t tmp;
	
	command = uart_getc();
	switch (command){
		case 'm':
			monitor();
			break;
		case 'd':
			f_opendir( &dir, "/");		
			tmp=0;
			while(1){
				f_readdir(&dir, &filinfo);
				if(filinfo.fname[0] == 0) break;
				hexprint8(tmp);
				tmp++;
				print (" ");
				print(filinfo.fname);
				print("\r\n");
			}
			break;
		case 'l':
			tmp = gethex16()+1;
			f_opendir( &dir, "/");		
			while(tmp--){
				f_readdir(&dir, &filinfo);
			}
			f_open(&fil, filinfo.fname, FA_READ|FA_OPEN_EXISTING);
			read_d64_file(&fil);
			f_close(&fil);
			break;
	}
}


uint8_t button_old;
uint8_t button_pressed;

uint8_t switch_old;
uint8_t switch_changed;

uint8_t read_keys(){
	uint8_t button, swtch;
	uint8_t retval = 0;
	
	button = BUTTON_I;
	if(button_old != button){
		button_pressed = button & ~button_old;
		button_old = button;
		retval = 1;		
	}
	
	swtch = SWITCH_I;
	if(switch_old != swtch){
		switch_changed = switch_old ^ swtch;
		switch_old = swtch;
		retval = 1;
	}
	return retval;
}

typedef struct{
	uint8_t attrib;
	uint8_t name[15];
}menu_item_t;

static uint16_t menu_pos, menu_entries, disp_pos;
static menu_item_t menu[500];
static uint8_t path[64];

void read_dir(){
	f_opendir( &dir, path);		
	menu_entries = 0;
	menu_pos = 0;
	disp_pos = 0;
	
	while(1){
		f_readdir(&dir, &filinfo);
		if(filinfo.fname[0] == 0) break;
		menu[menu_entries].attrib = filinfo.fattrib;
		strcpy(menu[menu_entries].name, filinfo.fname);
		menu_entries++;
	}
}

void show_menu(){
	uint16_t pos, line, end;
	if(menu_pos > disp_pos+7){
		disp_pos = menu_pos - 7;	
	}else if(disp_pos > menu_pos){
		disp_pos = menu_pos;	
	}
	end = disp_pos+8;
	if(end > menu_entries) end = menu_entries;
	dispSetPos(0,0);
	line = 0;
	for(pos=disp_pos;pos < end;pos++){
		line++;
		if(pos == menu_pos) dispPrint("\r");
		dispPrint(menu[pos].name);
		dispFillLine();
		if(pos == menu_pos) dispPrint("\r");
		dispPrint("\n");
	}
	while(line < 8){
		dispFillLine();
		dispPrint("\n");
		line++;
	}
}

void dir_up(){
	uint8_t i;
	i = strlen(path);
	for(i--; i != 0xff; i--){
		if(path[i] == '/'){
			path[i] = 0;
			break;				
		}
	}
}

void handle_keys(){	
	if(button_pressed & 0x02){
		menu_pos++;
		if(menu_pos >= menu_entries) menu_pos--;
	}
	if(button_pressed & 0x04){
		if(menu_pos != 0) menu_pos--;
	}
	
	if(button_pressed & 0x06){
		show_menu();	
	}

	if(button_pressed & 0x01){
		if (menu[menu_pos].attrib == AM_DIR){
			strcat(path, "/");
			strcat(path, menu[menu_pos].name);
			read_dir();
			show_menu();
		}else{
			strcat(path, "/");
			strcat(path, menu[menu_pos].name);
			f_open(&fil, path, FA_READ|FA_OPEN_EXISTING);
			dispClear();
			dispSetPos(0,0);
			dispPrint("Loading...");
			read_d64_file(&fil);
			f_close(&fil);
			dir_up();
			show_menu();
		}
	}

	if(button_pressed & 0x08){
		dir_up();
		read_dir();
		show_menu();
	}
	
}


int main(){
	FRESULT fresult;
	//is allready inited from bootloader
	//uart_init();
	uart_putstr("Application>\r\n");
	
	dispInit();
	dispClear();
	
	memset(&fs, 0, sizeof(FATFS)); 	/* Clear file system object */
	FatFs = &fs;					/* Assign it to the FatFs module */

	dispPrint("* FPGA Floppy  *\nloading ROM...\n");
	
	fresult = f_open(&fil, "sys/1541.rom", FA_READ|FA_OPEN_EXISTING);
	
	if(fresult){
		switch(fresult){
			case FR_NO_FILE:
			case FR_NO_PATH:
				dispPrint("sys/1541.rom\nnot found.\n");
				break;
			case FR_NOT_READY:
				dispPrint("no MMC/SD card.\n");
				break;
			case FR_NO_FILESYSTEM:
				dispPrint("no FAT\nfilesystem.\n");
				break;
		}
	}else{
		//00001111 11000000  00000000 --  0fC0:00 //floppy rom location start
		uint16_t page;
		WORD fsize;

		for(page = 0xfC0;page < 0x1000 ;page++){
			PAGE_REG = page;
			f_read (&fil, PAGE_DATA, 0x100, &fsize);
			if(fsize != 0x100){
				dispPrint("ROM to small.\n");
				break;
			}
		}
		f_close(&fil);
		if(page == 0x1000 ){
			dispPrint("starting floppy\n");
			RESET_O = 1;
			WPE_O = 1;
		}
	}
	
	path[0] = 0;
	read_dir();
	show_menu();
	
	while(1){
		if(uart_data_available()){
			handle_uart();	
		}	
		if(read_keys()){
			handle_keys();	
		}
	}
}
