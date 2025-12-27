# Makefile

# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog

export PYTHONPATH := $(PWD)/..

VERILOG_SOURCES += ../src/uart/fifo.sv

# Toplevel Verilog module 
COCOTB_TOPLEVEL = fifo

# Python test basename 
COCOTB_TEST_MODULES = tests.test_fifo

# Make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim


