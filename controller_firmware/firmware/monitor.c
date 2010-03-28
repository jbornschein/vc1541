#include <stdint.h>
#include <stdlib.h>

#include "config.h"
#include "uart.h"
#include "util.h"

//page of mem we are working on
uint8_t page;

uint8_t readmem(uint8_t * addr){
	PAGE_REG = ((uint16_t)page<<8) | ((uint16_t)addr>>8);
	return PAGE_DATA[(uint8_t)addr];
}

uint16_t readmem16(uint8_t * addr){
	uint16_t val;
	PAGE_REG = ((uint16_t)page<<8) | ((uint16_t)addr>>8);
	if((uint8_t)addr != 0xff){
		return *(uint16_t*)(&PAGE_DATA[(uint8_t)addr]);	
	}else{
		val = PAGE_DATA[(uint8_t)addr];
		addr++;
		PAGE_REG = ((uint16_t)page<<8) | ((uint16_t)addr>>8);
		val |= (uint16_t)PAGE_DATA[(uint8_t)addr] << 8;
		return val;
	}
}


enum mnemonic_e{
	BRK = 0, BPL = 1, JSR = 2, BMI = 3, RTI = 4, BVC = 5, RTS = 6, BVS = 7,
	BCC = 8, LDY = 9, BCS = 10, CPY = 11, BNE = 12, CPX = 13, BEQ = 14, ORA = 15,
	AND = 16, EOR = 17, ADC = 18, STA = 19, LDA = 20, CMP = 21, SBC = 22, LDX = 23,
	BIT = 24, STY = 25, STX = 26, ASL = 27, ROL = 28, LSR = 29, ROR = 30, DEC = 31,
	INC = 32, PHP = 33, CLC = 34, PLP = 35, SEC = 36, PHA = 37, CLI = 38, PLA = 39,
	SEI = 40, DEY = 41, TYA = 42, TAY = 43, CLV = 44, INY = 45, CLD = 46, INX = 47,
	SED = 48, TXA = 49, TXS = 50, TAX = 51, TSX = 52, DEX = 53, NOP = 54, JMP = 55,
	ILL = 56
};

char mnemonic_name[] =
	"BRK" "BPL" "JSR" "BMI" "RTI" "BVC" "RTS" "BVS"
	"BCC" "LDY" "BCS" "CPY" "BNE" "CPX" "BEQ" "ORA"
	"AND" "EOR" "ADC" "STA" "LDA" "CMP" "SBC" "LDX"
	"BIT" "STY" "STX" "ASL" "ROL" "LSR" "ROR" "DEC"
	"INC" "PHP" "CLC" "PLP" "SEC" "PHA" "CLI" "PLA"
	"SEI" "DEY" "TYA" "TAY" "CLV" "INY" "CLD" "INX"
	"SED" "TXA" "TXS" "TAX" "TSX" "DEX" "NOP" "JMP"
	"ILL";

enum mode_e{
	m_imp, m_rel, m_abs, m_imm, m_indx, m_indy,
	m_zp, m_zpx, m_zpy, m_absy, m_ind, m_absx,	
};

typedef struct{
	uint8_t mnemonic;
	uint8_t mode;	
}opcode_t;

opcode_t opcode[256] = {
	{BRK, m_imp}, {ORA, m_indx}, {ILL, 0}, {ILL, 0}, {ILL, 0}, {ORA, m_zp}, {ASL, m_zp}, {ILL, 0}, {PHP, m_imp}, {ORA, m_imm}, {ASL, m_imp}, {ILL, 0}, {ILL, 0}, {ORA, m_abs}, {ASL, m_abs}, {ILL, 0},
	{BPL, m_rel}, {ORA, m_indy}, {ILL, 0}, {ILL, 0}, {ILL, 0}, {ORA, m_zpx}, {ASL, m_zpx}, {ILL, 0}, {CLC, m_imp}, {ORA, m_absy}, {ILL, 0}, {ILL, 0}, {ILL, 0}, {ORA, m_absx}, {ASL, m_absx}, {ILL, 0},
	{JSR, m_abs}, {AND, m_indx}, {ILL, 0}, {ILL, 0}, {BIT, m_zp}, {AND, m_zp}, {ROL, m_zp}, {ILL, 0}, {PLP, m_imp}, {AND, m_imm}, {ROL, m_imp}, {ILL, 0}, {BIT, m_abs}, {AND, m_abs}, {ROL, m_abs}, {ILL, 0},
	{BMI, m_rel}, {AND, m_indy}, {ILL, 0}, {ILL, 0}, {ILL, 0}, {AND, m_zpx}, {ROL, m_zpx}, {ILL, 0}, {SEC, m_imp}, {AND, m_absy}, {ILL, 0}, {ILL, 0}, {ILL, 0}, {AND, m_absx}, {ROL, m_absx}, {ILL, 0},
	{RTI, m_imp}, {EOR, m_indx}, {ILL, 0}, {ILL, 0}, {ILL, 0}, {EOR, m_zp}, {LSR, m_zp}, {ILL, 0}, {PHA, m_imp}, {EOR, m_imm}, {LSR, m_imp}, {ILL, 0}, {JMP, m_abs}, {EOR, m_abs}, {LSR, m_abs}, {ILL, 0},
	{BVC, m_rel}, {EOR, m_indy}, {ILL, 0}, {ILL, 0}, {ILL, 0}, {EOR, m_zpx}, {LSR, m_zpx}, {ILL, 0}, {CLI, m_imp}, {EOR, m_absy}, {ILL, 0}, {ILL, 0}, {ILL, 0}, {EOR, m_absx}, {LSR, m_absx}, {ILL, 0},
	{RTS, m_imp}, {ADC, m_indx}, {ILL, 0}, {ILL, 0}, {ILL, 0}, {ADC, m_zp}, {ROR, m_zp}, {ILL, 0}, {PLA, m_imp}, {ADC, m_imm}, {ROR, m_imp}, {ILL, 0}, {JMP, m_ind}, {ADC, m_abs}, {ROR, m_abs}, {ILL, 0},
	{BVS, m_rel}, {ADC, m_indy}, {ILL, 0}, {ILL, 0}, {ILL, 0}, {ADC, m_zpx}, {ROR, m_zpx}, {ILL, 0}, {SEI, m_imp}, {ADC, m_absy}, {ILL, 0}, {ILL, 0}, {ILL, 0}, {ADC, m_absx}, {ROR, m_absx}, {ILL, 0},

	{ILL, 0}, {STA, m_indx}, {ILL, 0}, {ILL, 0}, {STY, m_zp}, {STA, m_zp}, {STX, m_zp}, {ILL, 0}, {DEY, m_imp}, {ILL, 0}, {TXA, m_imp}, {ILL, 0}, {STY, m_abs}, {STA, m_abs}, {STX, m_abs}, {ILL, 0},
	{BCC, m_rel}, {STA, m_indy}, {ILL, 0}, {ILL, 0}, {STY, m_zpx}, {STA, m_zpx}, {STX, m_zpy}, {ILL, 0}, {TYA, m_imp}, {STA, m_absy}, {TXS, m_imp}, {ILL, 0}, {ILL, 0}, {STA, m_absx}, {ILL, 0}, {ILL, 0},
	{LDY, m_imm}, {LDA, m_indx}, {LDX, m_imm}, {ILL, 0}, {LDY, m_zp}, {LDA, m_zp}, {LDX, m_zp}, {ILL, 0}, {TAY, m_imp}, {LDA, m_imm}, {TAX, m_imp}, {ILL, 0}, {LDY, m_abs}, {LDA, m_abs}, {LDX, m_abs}, {ILL, 0},
	{BCS, m_rel}, {LDA, m_indy}, {ILL, 0}, {ILL, 0}, {LDY, m_zpx}, {LDA, m_zpx}, {LDX, m_zpy}, {ILL, 0}, {CLV, m_imp}, {LDA, m_absy}, {TSX, m_imp}, {ILL, 0}, {LDY, m_absx}, {LDA, m_absx}, {LDX, m_absy}, {ILL, 0},
	{CPY, m_imm}, {CMP, m_indx}, {ILL, 0}, {ILL, 0}, {CPY, m_zp}, {CMP, m_zp}, {DEC, m_zp}, {ILL, 0}, {INY, m_imp}, {CMP, m_imm}, {DEX, m_imp}, {ILL, 0}, {CPY, m_abs}, {CMP, m_abs}, {DEC, m_abs}, {ILL, 0},
	{BNE, m_rel}, {CMP, m_indy}, {ILL, 0}, {ILL, 0}, {ILL, 0}, {CMP, m_zpx}, {DEC, m_zpx}, {ILL, 0}, {CLD, m_imp}, {CMP, m_absy}, {ILL, 0}, {ILL, 0}, {ILL, 0}, {CMP, m_absx}, {DEC, m_absx}, {ILL, 0},
	{CPX, m_imm}, {SBC, m_indx}, {ILL, 0}, {ILL, 0}, {CPX, m_zp}, {SBC, m_zp}, {INC, m_zp}, {ILL, 0}, {INX, m_imp}, {SBC, m_imm}, {NOP, m_imp}, {ILL, 0}, {CPX, m_abs}, {SBC, m_abs}, {INC, m_abs}, {ILL, 0},
	{BEQ, m_rel}, {SBC, m_indy}, {ILL, 0}, {ILL, 0}, {ILL, 0}, {SBC, m_zpx}, {INC, m_zpx}, {ILL, 0}, {SED, m_imp}, {SBC, m_absy}, {ILL, 0}, {ILL, 0}, {ILL, 0}, {SBC, m_absx}, {INC, m_absx}, {ILL, 0},
};




void printmnemonic(uint8_t mn){
	uint8_t * p;
	p = &mnemonic_name[mn*3];
	putc(*p++);
	putc(*p++);
	putc(*p);
}

void disassemble(uint8_t *addr, uint8_t len){
	uint8_t op;
	uint16_t tmp;
	while(len--){
		hexprint16((uint16_t)addr);
		op = readmem(addr);
		addr++;
		print("\t");
		printmnemonic(opcode[op].mnemonic);
		if(opcode[op].mnemonic == ILL){
			hexprint8(op);
		}
		print(" ");
		switch(opcode[op].mode){
		case m_imp:
			break;
		case m_rel:
			tmp = (uint16_t)addr;
			tmp += 1;
			tmp += readmem(addr);
			if (readmem(addr)>=0x80) tmp-=0x100;
			hexprint16(tmp);
			addr++;
			break;
		case m_abs:
			hexprint16(readmem16(addr));
			addr+=2;
			break;
		case m_imm:
			print("#");
			hexprint8(readmem(addr));
			addr++;
			break;
		case m_indx:
			print("(");
			hexprint8(readmem(addr));
			addr++;
			print(",x)");
			break;
		case m_indy:
			print("(");
			hexprint8(readmem(addr));
			addr++;
			print("),y");
			break;
		case m_zp:
			hexprint8(readmem(addr));
			addr++;
			break;
		case m_zpx:
			hexprint8(readmem(addr));
			addr++;
			print(",x");
			break;
		case m_zpy:
			hexprint8(readmem(addr));
			addr++;
			print(",y");
			break;
		case m_absx:
			hexprint16(readmem16(addr));
			addr+=2;
			print(",x");
			break;
		case m_absy:
			hexprint16(readmem16(addr));
			addr+=2;
			print(",y");
			break;
		case m_ind:
			print("(");
			hexprint16(readmem16(addr));
			addr += 2;
			print(")");		
		}
		
		print("\r\n");
	}
}

void hexdump_m(uint8_t * addr, uint16_t size){
	uint8_t x, c, sbuf[3];
	x=0;
	
	while(size--){
		c = readmem(addr);
		itoa(c, sbuf, 16);
		addr++;
		if (sbuf[1] == 0) print("0");
		print(sbuf);
		print(" ");
		if(++x == 16){
			print("\r\n");
			x = 0;
		}
	}
}

void hexdump_a(uint16_t size){
	uint8_t x, sbuf[5];
	uint16_t c;
	uint32_t addr;
	x=0;
	
	addr = 0x0c0000l + ((uint32_t)LOG_ADDR<<1) - (size << 2);
	
	while(size--){
		page = addr >> 16;
		c = readmem16((uint8_t *)(uint16_t)addr);
		itoa(c, sbuf, 16);
		addr += 2;
		if (sbuf[1] == 0) print("000");
		else if (sbuf[2] == 0) print("00");
		else if (sbuf[3] == 0) print("0");
		print(sbuf);
		print(":");
		c = readmem((uint8_t *)(uint16_t)addr);
		itoa(c, sbuf, 16);
		addr += 2;
		if (sbuf[1] == 0) print("0");
		print(sbuf);
		print(" ");
		if(++x == 8){
			print("\r\n");
			x = 0;
		}
	}
}

void dumpv(uint8_t track){
	uint16_t bank;
	uint16_t end;
	end = 0x23 + 0x40 * track;
	for(bank= 0x40 * track ; bank < end; bank++){
		PAGE_REG = bank; 
		hexdump(PAGE_DATA, 0x100);	
	}
}



void monitor(){
	uint8_t *addr;
	uint16_t size;
	uint8_t command;
	page = 0x0f; //floppy memory
	print("Monitor\r\n");
	while(1){
		command = getc();
		putc(command);
		putc(' ');
		switch (command){
			case 'a':
				//page = 0x0d;
				hexdump_a(0x80);
				page = 0x0f;
				break;
			case 'A':
				//print("how many adresses ? ");
				size = gethex16();
				print ("\r\n");
				//page = 0x0d;
				hexdump_a(size);
				page = 0x0f;
				break;
			case 't':
				size = gethex16();
				dumpv(size);
				break;
			case 'd':
				print("addr? ");
				addr = (uint8_t*)gethex16();
				print("\r\n");
				disassemble(addr, 30);
				break;
			case 'm':
				print("addr? ");
				addr = (uint8_t*)gethex16();
				print(" size? ");
				size = gethex16();
				print("\r\n");
				hexdump_m(addr, size);
				break;
			case 'b':
				print("addr? ");
				addr = (uint8_t*)gethex16();
				print("\r\n");
				D_B_ENABLE = 0x00;
				D_BPX0 = (uint16_t)addr;
				D_B_FLAG = 0xff;
				D_B_ENABLE = 0x01;
				break;
			case 'r':
				print ("regs: A=");
				hexprint8(D_A);
				print (" X=");
				hexprint8(D_X);
				print (" Y=");
				hexprint8(D_Y);
				print (" P=");
				hexprint8(D_P);
				print("\r\n");
				break;
			case 'w':
				while(1){
					if (uart_data_available()){
						uart_getc();
						print("break\r\n");
						break;
					}
					if(D_B_FLAG != 0){
						print ("breakpoint\r\n");
						break;						
					}
				}
				break;
			case 'c':
				D_B_FLAG = 0xff;
				break;
			case 'x':
				return;
		}
	}
}
