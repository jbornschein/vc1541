
#include <string.h>
#include "vdisk.h"
#include "util.h"
#include "config.h"

#include "uart.h"

#undef getc

#define getc file_getc

static uint16_t page_addr;
static uint8_t addr;

static FIL * fil;

uint8_t file_getc(){
	uint8_t c;
	WORD n;
	f_read(fil, &c, 1, &n);
	return c;
}

void vd_set_track(uint8_t track){
	track -= 1;
	page_addr = (track << 6);
	PAGE_REG = page_addr;
	addr = 0;
}

void inc_page(){
	page_addr++;
	PAGE_REG = page_addr;	
}


void vd_write_raw(uint8_t value, uint16_t times){
	while(times--){
		PAGE_DATA[addr] = value;
		addr++;
		if(addr == 0){
			inc_page();	
		}		
	}
};

void vd_inc_addr(uint8_t val){
	uint8_t oldaddr;
	oldaddr = addr;
	addr += val;
	if(oldaddr > addr){
		inc_page();	
	}
}

void vd_clear(){
	uint16_t p;
	uint8_t a=0;
	for(p=0;p<0x8c0;p++){
		PAGE_REG = p;
		do{
			PAGE_DATA[a] = 0x55;
			a++;	
		}while(a);
	}	
}

void vd_write_gcr(uint8_t * data, uint8_t num_quads){
	uint8_t tmp;
	while(num_quads--){
		memcpy(GCR_REG, data, 4);
		data += 4;
		
		if(addr < 252){
			memcpy((uint8_t *)(PAGE_DATA + addr), (uint8_t *)GCR_REG, 5);
			addr += 5;
			if(addr == 0) inc_page();
		}else{
			tmp = addr + 5;
			memcpy(&PAGE_DATA[addr], (uint8_t *)GCR_REG, 5-tmp);
			inc_page();
			memcpy(&PAGE_DATA[0], (uint8_t *)(GCR_REG + 5-tmp), tmp);
			addr += 5;
		}
	}	
}


struct sector_header{
	uint8_t mark;
	uint8_t cks;
	uint8_t sector;
	uint8_t track;
	uint8_t id2;
	uint8_t id1;
	uint8_t fill1;
	uint8_t fill2;
}; 

uint8_t secbuf[260];

void vd_write_sector(uint8_t track, uint8_t sector, uint16_t id){
	uint8_t x, tmp, cks;
	WORD n;
	uint8_t * pt;
	static struct sector_header header = {0x08,0,0,0,0,0,0x0f,0x0f};
	
	header.sector = sector;
	header.track = track;
	header.id2 = id & 0xff;
	header.id1 = id >> 8;
	header.cks = header.sector ^ header.track ^ header.id1 ^ header.id2;
	vd_write_raw(0xFF, 5);
	vd_write_gcr((uint8_t *)&header, 2);
	//vd_inc_addr(9);
	vd_write_raw(0x55, 9);
	vd_write_raw(0xFF, 5);
	
	secbuf[0] = 0x07;
	
	f_read(fil, &secbuf[1], 256, &n);
	
	cks = 0;
	
	pt = &secbuf[1];
	x=0;
	do{
		cks ^= pt[x];
		x++;
	}while(x!= 0);

	secbuf[257] = cks;
	
	secbuf[258] = 0;
	secbuf[259] = 0;
	
	vd_write_gcr(secbuf, 65);
}

/*
void vd_write_sector(uint8_t track, uint8_t sector, uint16_t id){
	uint8_t x, tmp, cks;
	uint8_t buf[4];
	static struct sector_header header = {0x08,0,0,0,0,0,0x0f,0x0f};
	
	header.sector = sector;
	header.track = track;
	header.id2 = id & 0xff;
	header.id1 = id >> 8;
	header.cks = header.sector ^ header.track ^ header.id1 ^ header.id2;
	vd_write_raw(0xFF, 5);
	vd_write_gcr((uint8_t *)&header, 2);
	vd_inc_addr(9);
	vd_write_raw(0xFF, 5);
	
	buf[0] = 0x07;
	cks = 0;
	
	for(x=0; x<64; x++){
		tmp = getc();
		buf[1] = tmp;
		cks ^= tmp;
		
		tmp = getc();
		buf[2] = tmp;
		cks ^= tmp;
		
		tmp = getc();
		buf[3] = tmp;
		cks ^= tmp;
		
		vd_write_gcr(buf, 1);
		
		tmp = getc();
		buf[0] = tmp;
		cks ^= tmp;
	}
	
	buf[1] = cks;
	buf[2] = 0x00;
	buf[3] = 0x00;
	vd_write_gcr(buf, 1);
}
*/


void vd_write_d64(){
	uint8_t track, sector;
	uint16_t id = 0x3030;
	
	track = 1;
	//print("Clearing...");
	//vd_clear();
	print("Loading...\r\n");
	
	
	while(track < 18){
		vd_set_track(track);
		for(sector = 0; sector < 21; sector++){
			vd_write_sector(track, sector, id);
			//vd_inc_addr(11);
			vd_write_raw(0x55, 11);
		}
		vd_write_raw(0x55, 30);
		track++;
	}
	
	while(track < 25){
		vd_set_track(track);
		for(sector = 0; sector < 19; sector++){
			vd_write_sector(track, sector, id);
			//vd_inc_addr(21);
			vd_write_raw(0x55, 21);
		}
		vd_write_raw(0x55, 30);
		track++;
	}
	
	while(track < 31){
		vd_set_track(track);
		for(sector = 0; sector < 18; sector++){
			vd_write_sector(track, sector, id);
			//vd_inc_addr(15);
			vd_write_raw(0x55, 15);
		}
		vd_write_raw(0x55, 30);
		track++;
	}
	
	while(track < 36){
		vd_set_track(track);
		for(sector = 0; sector < 17; sector++){
			vd_write_sector(track, sector, id);
			//vd_inc_addr(12);
			vd_write_raw(0x55, 12);
		}
		vd_write_raw(0x55, 30);
		track++;
	}
	
	print ("done\r\n");

}

void read_d64_file(FIL * file){
	fil = file;
	vd_write_d64();
}
