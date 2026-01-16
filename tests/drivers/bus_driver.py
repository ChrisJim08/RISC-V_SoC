import cocotb

class BusDriver:
  def __init__(self, dut):
    self.dut = dut
  
  async def driver(self, addr, data):
    self.dut.bus_addr_i = addr
    self.dut.bus_data_i = addr