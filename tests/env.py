from agents.uart_agent import UartAgent 
from agents.bus_agent import BusAgent
from scoreboards.uart_scoreboard import UartScoreboard
class Env:
  def __init__(self, dut):
    self.uart_agent = UartAgent(dut)
    self.bus_agent = BusAgent(dut)
    self.uart_scoreboard = UartScoreboard()
    
    