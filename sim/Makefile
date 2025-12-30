# Makefile

# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES ?= $(shell find $(PWD)/../src -name "*.sv" -o -name "*.svh")
VERILOG_INCLUDE_DIRS += $(PWD)/../src/uart
export PYTHONPATH := $(PWD)/..:$(PYTHONPATH)

# Make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

# Define specific targets for different modules
.PHONY: test_fifo test_uart

cleanbuild:
	rm -rf sim_build

test_fifo:
	$(MAKE) COCOTB_TOPLEVEL=fifo COCOTB_TEST_MODULES=tests.test_fifo

test_uart_rx:
	$(MAKE) COCOTB_TOPLEVEL=uart_rx COCOTB_TEST_MODULES=tests.test_uart_rx

test_uart_tx:
	$(MAKE) COCOTB_TOPLEVEL=uart_tx COCOTB_TEST_MODULES=tests.test_uart_tx

test_uart:
	$(MAKE) COCOTB_TOPLEVEL=uart COCOTB_TEST_MODULES=tests.test_uart


