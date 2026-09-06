# vc1541

FPGA-based emulator of a Commodore 1541 disk drive, targeting a Xilinx
Spartan-3 board.

## Layout

- `*.vhd`, `ledtest.ise` — FPGA gateware (Xilinx ISE project).
- `controller_firmware/` — 6502 firmware for the on-board LCD/SD controller
  (built with a [cc65](https://cc65.github.io/) fork; see `Makefile`).
- `rom2vhdl/` — helper tool that converts a firmware ROM image into a VHDL
  memory initialization file (plain C, builds with `gcc`/`make`).
- `debug/` — misc. debugging notes and assembly listings.

## Building

The gateware requires Xilinx ISE. The firmware requires the specific cc65
fork referenced in `controller_firmware/Makefile`. Neither is vendored in
this repository.

## History

Imported from a legacy Subversion repository.
