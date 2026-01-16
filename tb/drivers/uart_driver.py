import cocotb
class UartDriver:
  def __init__(self, dut):
    self.dut = dut
    
  async def receive_byte(self, byte):
    pass