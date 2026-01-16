import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

# TODO: Correct comments as I continue to learn and actually implement my bus
# Bus Functional Model
class BusDriver:
  def __init__(self, dut):
    self.dut = dut
  
  # Simulates bus writing into slave
  async def write(self, addr, data):
    dut = self.dut
    
    await RisingEdge(dut.clk_i)
    dut.bus_wr_en_i.value = 1
    dut.bus_addr_i.value  = addr
    dut.bus_wdata_i.value  = data
    
    await RisingEdge(dut.clk_i)
    dut.bus_wr_en_i.value = 0
  
  # Reads slave's response onto bus
  async def read(self, addr):
    dut = self.dut
    
    await RisingEdge(dut.clk_i)
    dut.bus_addr_i.value = addr
    
    await RisingEdge(dut.clk_i)
    return dut.rdata_o.value
    