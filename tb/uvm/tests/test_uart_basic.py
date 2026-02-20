import cocotb
import logging
from cocotb.clock import Clock

async def generate_clock(dut):
  clock = Clock(dut.clk_i, 10, unit="ns")
  await cocotb.start_soon(clock.start())
  
class Driver:
  def __init__(self, dut):
    self.dut = dut
  
@cocotb.test()
async def test_uart_basic(dut):
  cocotb.start_soon(generate_clock(dut))
  