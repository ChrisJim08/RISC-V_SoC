from drivers.bus_driver import BusDriver
from monitors.bus_monitor import BusMonitor
class BusAgent:
  def __init__(self, dut):
    self.driver  = BusDriver(dut)
    self.monitor = BusMonitor(dut)
  
  async def write(self, addr, data):
      self.driver.drive()
    pass
  
  async def sequencer_or_queue():
    pass
  