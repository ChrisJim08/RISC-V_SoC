from agents.uart_agent import UartAgent 
from scoreboards.uart_scoreboard import UartScoreboard
class Env:
  def __init__(self, dut):
    self.uart_agent = UartAgent(dut)
    self.uart_scoreboard = UartScoreboard()
    
    