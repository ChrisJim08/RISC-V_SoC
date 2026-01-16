from sequences.random_uart_seq import RandomUartSeq
from drivers.uart_driver import UartDriver
from monitors.uart_monitor import UartMonitor
class UartAgent:
  
  def __init__(self, dut, ):
    self.driver  = UartDriver(dut)
    self.monitor = UartMonitor(dut)
    
  async def sequencer_or_queue():
    pass
  
  def send_byte():
    pass
  
  def re