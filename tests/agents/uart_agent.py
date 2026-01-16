from sequences.random_uart_seq import RandomUartSeq
from drivers.uart_driver import UartDriver
from monitors.uart_monitor import UartMonitor
class UartAgent:
  
  def __init__(self, dut, ):
    self.driver  = UartDriver(dut)
    self.monitor = UartMonitor(dut)
  
  # TODO: Is a sequencer even needed
  async def sequencer_or_queue():
    pass
  
  async def receive_byte(self, byte):
    self.driver.receive_byte(byte)
  