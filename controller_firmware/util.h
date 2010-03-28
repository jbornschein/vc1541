/*
	Some usefull makros
*/

#include <stdint.h>


#define outb(addr,byte) (*((unsigned char *)addr) = byte)
#define inb(addr) *((unsigned char *)addr)

//#define REG(addr) *((unsigned char*)addr)
//#define REG16(addr) *((unsigned int*)addr)


/* functions */
void hexdump(unsigned char * addr, unsigned char size);
