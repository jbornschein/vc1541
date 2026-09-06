CC ?= cc

all: rom2vhdl makechartable

rom2vhdl: rom2vhdl.c
	$(CC) -O2 -o $@ $<

makechartable: makechartable.c
	$(CC) -O2 -o $@ $<

.PHONY: clean
clean:
	$(RM) rom2vhdl makechartable
