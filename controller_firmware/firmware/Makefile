#
# Makefile for cc65 samples
#
# This Makefile requires GNU make
#

PRG	=	firmware
OBJ	=	startup.o main.o uart.o util.o vdisk.o monitor.o ff.o mmc.o ks0108.o font_c64.o

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
	$(CC) -Oirs -T  --codesize 500 -g $<
	$(AS) $(basename $<).s

.S.o:
	@echo $<
	$(AS) $(ASFLAGS) $(basename $<).S


# --------------------------------------------------------------------------
# Rules how to make each one of the binaries

all: $(PRG).prg


$(PRG).prg: 	$(CRT0) $(OBJ) $(CLIB)
	$(LD) -C firmware.cfg -m $(basename $@).map -o $@ $^
	dd bs=1 skip=5 if=firmware.upl of=firmware.bin

#perl -e 'print "u\x04\x00\x01\xf1" '>firmware.up
#cat firmware.bin >> firmware.up
#perl -e 'print "j\x04\x00" '>>firmware.up

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
