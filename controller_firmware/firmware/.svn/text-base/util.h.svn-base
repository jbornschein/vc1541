#ifndef UTIL_H
#define UTIL_H

#include <stdint.h>

/*
	Some usefull makros
*/


#define outb(addr,byte) (*((unsigned char *)addr) = byte)
#define inb(addr) *((unsigned char *)addr)

//#define REG(addr) *((unsigned char*)addr)
//#define REG16(addr) *((unsigned int*)addr)


void hexdump(unsigned char * addr, unsigned int size);
void hexprint16(uint16_t i);
void hexprint8(uint8_t i);
uint16_t gethex16();



#endif
