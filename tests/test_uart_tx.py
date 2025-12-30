import cocotb
import random
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

async def generate_clock(dut):
  # Keep the clock running forever in the background
  clock = Clock(dut.clk_i, 10, unit="ns")
  await cocotb.start_soon(clock.start())
  
class UartDriver:
    def __init__(self, dut, baud_rate_ticks):
        self.dut = dut
        self.baud_rate_ticks = baud_rate_ticks

    async def transmit_byte(self, data):
        """transmits a byte of data over the parallel line."""
        
        # Transmit data byte over UART protocol
        self.dut.data_i.value = data
        self.dut.dv_i.value   = 1
        cocotb.log.info(f"txd_o: 0x{self.dut.txd_o.value} busy_o:{self.dut.busy_o.value}")
        await ClockCycles(self.dut.clk_i, 1)
        self.dut.dv_i.value   = 0
        cocotb.log.info(f"Transmitting: 0x{self.dut.data_i.value}")
        cocotb.log.info(f"txd_o: 0x{self.dut.txd_o.value} busy_o:{self.dut.busy_o.value}")
        
        await self.pulse_tick()
        cocotb.log.info(f"txd_o: 0x{self.dut.txd_o.value} busy_o:{self.dut.busy_o.value}")
        await self.pulse_tick()
        cocotb.log.info(f"txd_o: 0x{self.dut.txd_o.value} busy_o:{self.dut.busy_o.value}")
        await self.pulse_tick()
        cocotb.log.info(f"txd_o: 0x{self.dut.txd_o.value} busy_o:{self.dut.busy_o.value}")
        await self.pulse_tick()
        cocotb.log.info(f"txd_o: 0x{self.dut.txd_o.value} busy_o:{self.dut.busy_o.value}")
        await self.pulse_tick()
        cocotb.log.info(f"txd_o: 0x{self.dut.txd_o.value} busy_o:{self.dut.busy_o.value}")
        await self.pulse_tick()
        cocotb.log.info(f"txd_o: 0x{self.dut.txd_o.value} busy_o:{self.dut.busy_o.value}")
        await self.pulse_tick()
        cocotb.log.info(f"txd_o: 0x{self.dut.txd_o.value} busy_o:{self.dut.busy_o.value}")
        await self.pulse_tick()
        cocotb.log.info(f"txd_o: 0x{self.dut.txd_o.value} busy_o:{self.dut.busy_o.value}")
        await self.pulse_tick()
        cocotb.log.info(f"txd_o: 0x{self.dut.txd_o.value} busy_o:{self.dut.busy_o.value}")
        await self.pulse_tick()
        cocotb.log.info(f"txd_o: 0x{self.dut.txd_o.value} busy_o:{self.dut.busy_o.value}")
        await self.pulse_tick()
        cocotb.log.info(f"txd_o: 0x{self.dut.txd_o.value} busy_o:{self.dut.busy_o.value}")
      

    async def pulse_tick(self):
        """Generates a single pulse on tick_i that lasts for one clock cycle at the correct time."""
        
        # Wait for the correct baud rate interval
        await ClockCycles(self.dut.clk_i, self.baud_rate_ticks)
        
        # Pulse the tick line for exactly one clock cycle
        self.dut.tick_i.value = 1
        await ClockCycles(self.dut.clk_i, 1) # Wait one clock cycle with tick_i high
        self.dut.tick_i.value = 0
        
        # The next call will handle the next baud interval delay
  
async def reset_dut(dut):
    """Apply reset sequence."""
    dut.rst_i.value = 1
    # Assuming reset needs at least 2 cycles to be stable
    await RisingEdge(dut.clk_i) 
    await RisingEdge(dut.clk_i) 
    dut.rst_i.value = 0
    await RisingEdge(dut.clk_i) # Wait one more cycle after reset release

@cocotb.test()
async def test_uart_tx(dut):
    cocotb.start_soon(generate_clock(dut))
    
    # Initialize signals to 0 safely before the first clock
    dut.rst_i.value  = 0
    dut.data_i.value = 1
    dut.tick_i.value = 0
    
    BAUD_TICKS = 1900
    uart_driver = UartDriver(dut, BAUD_TICKS)
    
    # Run the reset sequence
    await reset_dut(dut)
    cocotb.log.info("Reset complete.")









    # --- Send a test byte ---
    test_byte = 0x9A # 'A'
    await uart_driver.transmit_byte(test_byte)

    # Wait for the DUT to indicate valid data output (dv_o goes high)
    #await RisingEdge(dut.dv_o)
    
    # Read the data output
    received_data = dut.data_o.value.to_unsigned()
    cocotb.log.info(f"Received data: 0x{received_data:02X}")
    
    assert received_data == test_byte, f"UART Rx failed! Expected 0x{test_byte:02X}, got 0x{received_data:02X}"

    await ClockCycles(dut.clk_i, 10) # Run for a bit longer to end simulation
    
    cocotb.log.info("Test finished successfully!")