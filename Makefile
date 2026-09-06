# Run the VHDL testbenches under GHDL (https://ghdl.github.io/ghdl/,
# e.g. `apt install ghdl`).
#
# `make sim` runs all of them; `make sim-spi`, `make sim-m6522`,
# `make sim-t65` run one each. Pass WAVES=1 to also dump a VCD
# waveform into sim-work/ for viewing with gtkwave.

GHDL      ?= ghdl
BUILD_DIR := sim-work
GHDLFLAGS := --std=93 --ieee=synopsys -fexplicit --workdir=$(BUILD_DIR)

$(BUILD_DIR):
	mkdir -p $@

.PHONY: sim
sim: sim-spi sim-m6522 sim-t65

.PHONY: sim-spi
sim-spi: $(BUILD_DIR)
	$(GHDL) -a $(GHDLFLAGS) spi.vhd spi_testbench.vhd
	$(GHDL) -e $(GHDLFLAGS) spi_testbench
	$(GHDL) -r $(GHDLFLAGS) spi_testbench --stop-time=1us \
		$(if $(WAVES),--vcd=$(BUILD_DIR)/spi_testbench.vcd)

.PHONY: sim-m6522
sim-m6522: $(BUILD_DIR)
	$(GHDL) -a $(GHDLFLAGS) m6522.vhd m6522_tb.vhd
	$(GHDL) -e $(GHDLFLAGS) m6522_tb
	$(GHDL) -r $(GHDLFLAGS) m6522_tb --stop-time=1200us \
		$(if $(WAVES),--vcd=$(BUILD_DIR)/m6522_tb.vcd)

.PHONY: sim-t65
sim-t65: $(BUILD_DIR)
	$(GHDL) -a $(GHDLFLAGS) T65_Pack.vhd T65_MCode.vhd T65_ALU.vhd T65.vhd \
		t65_testrom.vhd t65_testbench.vhd
	$(GHDL) -e $(GHDLFLAGS) t65_testbench
	$(GHDL) -r $(GHDLFLAGS) t65_testbench --stop-time=10us \
		$(if $(WAVES),--vcd=$(BUILD_DIR)/t65_testbench.vcd)

.PHONY: clean-sim
clean-sim:
	$(RM) -r $(BUILD_DIR)
