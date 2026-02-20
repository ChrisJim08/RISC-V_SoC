# Makefile

# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog
# Put packages first, then everything else
PKG_SOURCES = \
  $(PWD)/../src/system_bus/memmap_pkg.sv

IF_SOURCES = \
  $(PWD)/../src/system_bus/bus_if.sv

ALL_SOURCES = $(shell find $(PWD)/../src/system_bus $(PWD)/../src/memory -name "*.sv" -o -name "*.svh")

VERILOG_SOURCES = \
  $(PKG_SOURCES) \
  $(IF_SOURCES) \
  $(filter-out $(PKG_SOURCES) $(IF_SOURCES), $(ALL_SOURCES)) \
	$(PWD)/../sim/test_wrappers/bus_fabric_top.sv

EXTRA_ARGS += --trace --trace-structs
VERILOG_INCLUDE_DIRS += $(PWD)/../src/system_bus
export PYTHONPATH := $(PWD)/..:$(PYTHONPATH)

# Make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

# Define specific targets for different modules
.PHONY: test_bus																	// TODO Needed?

cleanbuild:
	rm -rf sim_build

test_bus:
	$(MAKE) COCOTB_TOPLEVEL=bus_fabric_top COCOTB_TEST_MODULES=tb.tests.functional.test_bus


