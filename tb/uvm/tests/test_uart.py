import cocotb
from cocotb.clock import Clock

async def generate_clock(dut):
  clock = Clock(dut.clk_i, 10, unit="ns")
  await cocotb.start_soon(clock.start())
  
@cocotb.test()
async def test_uart(dut):
  # Start cycling clock
  cocotb.start_soon(generate_clock(dut))
  
  #env
  