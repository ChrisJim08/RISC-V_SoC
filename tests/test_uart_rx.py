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

    async def send_byte(self, data):
        """Sends a byte of data over the serial line."""
        
        # Start bit (logic low)
        self.dut.rxd_i.value = 0
        await self.pulse_tick()
        cocotb.log.info(f"state_reg: 0x{self.dut.state_reg.value}")

        # Data bits (LSB first)
        for i in range(8): # Assuming 8 DataWidth
            self.dut.rxd_i.value = (data >> i) & 1
            await self.pulse_tick()
            cocotb.log.info(f"Sending bit: 0x{self.dut.rxd_i.value}")
            cocotb.log.info(f"state_reg: 0x{self.dut.state_reg.value}")
            cocotb.log.info(f"rxd: 0x{self.dut.rxd.value}")
            cocotb.log.info(f"count_reg: 0x{self.dut.count_reg.value}")
            cocotb.log.info(f"sbuff_full: 0x{self.dut.sbuff_full.value}")
            cocotb.log.info(f"next_sbuff: 0x{self.dut.next_sbuff.value}")

        # Stop bit (logic high)
        self.dut.rxd_i.value = 1
        await self.pulse_tick()
        
        cocotb.log.info(f"valid_o: 0x{self.dut.valid_o.value}")
        
        # Return rxd_i to idle high state
        await self.pulse_tick()

    async def pulse_tick(self):
        """Generates a single pulse on baud_clk_i that lasts for one clock cycle at the correct time."""
        
        # Wait for the correct baud rate interval
        await ClockCycles(self.dut.clk_i, self.baud_rate_ticks)
        
        # Pulse the tick line for exactly one clock cycle
        self.dut.baud_clk_i.value = 1
        await ClockCycles(self.dut.clk_i, 1) # Wait one clock cycle with baud_clk_i high
        self.dut.baud_clk_i.value = 0
        
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
async def test_uart_rx(dut):
    cocotb.start_soon(generate_clock(dut))
    
    # Initialize signals to 0 safely before the first clock
    dut.rst_i.value  = 0
    dut.rxd_i.value = 1
    dut.baud_clk_i.value = 0
    
    BAUD_TICKS = 57600
    uart_driver = UartDriver(dut, BAUD_TICKS)
    
    # Run the reset sequence
    await reset_dut(dut)
    cocotb.log.info("Reset complete.")

    # --- Send a test byte ---
    test_byte = 0x9A # 'A'
    cocotb.log.info(f"Sending byte: 0x{test_byte:02X}")
    await uart_driver.send_byte(test_byte)

    # Wait for the DUT to indicate valid data output (valid_o goes high)
    #await RisingEdge(dut.valid_o)
    
    # Read the data output
    received_data = dut.data_o.value.to_unsigned()
    cocotb.log.info(f"Received data: 0x{received_data:02X}")
    
    assert received_data == test_byte, f"UART Rx failed! Expected 0x{test_byte:02X}, got 0x{received_data:02X}"

    await ClockCycles(dut.clk_i, 10) # Run for a bit longer to end simulation
    
    cocotb.log.info("Test finished successfully!")