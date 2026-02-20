# Simulator settings
SIM ?= verilator
TOPLEVEL_LANG ?= verilog

# -- Path Setup --
PROJ_ROOT = $(realpath $(PWD)/..)
SRC_DIR   = $(PROJ_ROOT)/src
WRAP_DIR  = $(PWD)/wrappers

# -- Source Files --

# 1. Packages must be compiled first
PKG_SRCS = $(SRC_DIR)/system_bus/memmap_pkg.sv

# 2. Interfaces
IF_SRCS = $(SRC_DIR)/system_bus/bus_if.sv

# 3. Simulation wrappers
WRAP_SRCS = $(WRAP_DIR)/bus_fabric_top.sv

# 4. All sources
ALL_SRCS = $(shell find $(SRC_DIR)/system_bus $(SRC_DIR)/memory -name "*.sv" -o -name "*.svh")

# 5. Source list in valid compilation order
VERILOG_SOURCES = \
  $(PKG_SRCS)  \
  $(IF_SRCS)   \
  $(WRAP_SRCS) \
  $(filter-out $(PKG_SRCS) $(IF_SRCS), $(ALL_SRCS))

# -- Compilation flags --

# Dump waveforms
EXTRA_ARGS += --trace --trace-structs

# Include directories for .svh files
VERILOG_INCLUDE_DIRS += $(SRC_DIR)/system_bus
VERILOG_INCLUDE_DIRS += $(SRC_DIR)/memory

# -- Cocotb configuration --
include $(shell cocotb-config --makefiles)/Makefile.sim

# -- Add parent directory --
export PYTHONPATH := $(PWD)/..:$(PYTHONPATH)

# -- Targets --

# Define specific targets for different modules
.PHONY: cleanbuild testbus

cleanbuild:
	rm -rf sim_build results.xml dump.vcd

testbus:
	$(MAKE) COCOTB_TOPLEVEL=bus_fabric_top COCOTB_TEST_MODULES=tb.tests.test_bus
