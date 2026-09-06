#
# Makefile for cc65 samples
#
# This Makefile requires GNU make
#

PRG	=	bootloader
OBJ	=	startup.o ks0108.o main.o uart.o util.o ff.o mmc.o font_c64.o

# Uses the standard cc65 toolchain (apt package "cc65"), targeting its
# generic "none" runtime — this project provides its own startup code
# and linker config rather than a cc65-supported system.
CC65_SHARE = /usr/share/cc65

CLIB	= $(CC65_SHARE)/lib/none.lib
CC	= cc65
CL	= cl65
AS	= ca65
LD	= ld65
C1541  	= c1541

ASFLAGS = -I$(CC65_SHARE)/asminc


# --------------------------------------------------------------------------
# Generic rules

.c.o:
	@echo $<
	$(CC) -T -Oirs --codesize 500 -g $<
	$(AS) $(basename $<).s

.S.o:
	@echo $<
	$(AS) $(ASFLAGS) $(basename $<).S


# --------------------------------------------------------------------------
# Rules how to make each one of the binaries

all: $(PRG).prg


$(PRG).prg: 	$(CRT0) $(OBJ) $(CLIB)
	$(LD) -C bootloader.cfg -m $(basename $@).map -o $@ $^
	perl -e 'print "\xff" x 8192'>>bootloader.bin
	dd bs=1024 count=16 if=bootloader.bin of=bootloader.rom
	$(MAKE) -C ../rom2vhdl
	../rom2vhdl/rom2vhdl bootloader.rom ctrlrom > ctrlrom.vhd

# --------------------------------------------------------------------------
# Rule to make a disk with all samples. Needs the c1541 program that comes
# with the VICE emulator.

.PHONY:	disk
disk:  	samples.d64

samples.d64:	all
	@$(C1541) -format samples,AA  d64 $@ > /dev/null
	@for exe in $(EXELIST); do\
	    $(C1541) -attach $@ -write $$exe > /dev/null;\
	done;\
	for tgi in ../libsrc/$(SYS)*.tgi; do\
	    $(C1541) -attach $@ -write $$tgi > /dev/null;\
	done;

# --------------------------------------------------------------------------
# Cleanup rules

.PHONY:	clean
clean:
	$(RM) *~ *.map *.o *.s *.lbl $(PRG).prg
