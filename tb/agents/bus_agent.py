from drivers.bus_driver import BusDriver
from monitors.bus_monitor import BusMonitor
class BusAgent:
  def __init__(self, dut):
    self.driver  = BusDriver(dut)
    self.monitor = BusMonitor(dut)
    
  # TODO: Is a sequencer even needed  
  async def sequencer_or_queue():
    pass
  
  async def write(self, addr, data):
    self.driver.write(addr, data)
  
  
  