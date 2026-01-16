class UartScoreboard:
  def __init__(self, bus_monitor, uart_monitor):
    self.bus_monitor  = bus_monitor
    self.uart_monitor = uart_monitor
    