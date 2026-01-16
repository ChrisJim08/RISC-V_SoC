import cocotb
class UartDriver:
  def __init__(self, dut):
    self.dut = dut
    
  async def driver(self, sequence_item):
    pass