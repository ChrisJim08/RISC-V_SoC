import cocotb
import random
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer

async def generate_clock(dut):
  # Keep the clock running forever in the background
  clock = Clock(dut.clk_i, 2, unit="ns")
  await cocotb.start_soon(clock.start())

async def reset_dut(dut):
    """Apply reset sequence."""
    dut.rst_i.value = 1
    # Assuming reset needs at least 2 cycles to be stable
    await RisingEdge(dut.clk_i) 
    await RisingEdge(dut.clk_i) 
    dut.rst_i.value = 0
    await RisingEdge(dut.clk_i) # Wait one more cycle after reset release

async def write_fifo(dut, data):
    """Write data to the FIFO."""
    # We must wait for the clock edge before we set the value for the setup time
    await RisingEdge(dut.clk_i) 
    dut.wr_en_i.value = 1
    dut.wr_data_i.value = data
    # We need to hold the enable high for one full cycle to register the data
    await RisingEdge(dut.clk_i) 
    dut.wr_en_i.value = 0 # Disable write after one cycle

async def read_fifo(dut):
    """Read data from the FIFO and return the value."""
    # Apply read enable before the edge, capture output on next edge
    await RisingEdge(dut.clk_i) 
    dut.rd_en_i.value = 1
    await RisingEdge(dut.clk_i) 
    dut.rd_en_i.value = 0
    await RisingEdge(dut.clk_i) 
    read_data = dut.rd_data_o.value
    return read_data

@cocotb.test()
async def test_fifo_randomized(dut):
    cocotb.start_soon(generate_clock(dut))
    
    # Initialize signals to 0 safely before the first clock
    dut.rst_i.value = 0
    dut.wr_en_i.value = 0
    dut.rd_en_i.value = 0
    dut.wr_data_i.value = 0
    
    # Run the reset sequence
    await reset_dut(dut)
    cocotb.log.info("Reset complete.")

    # --- Verification Environment (Scoreboard) ---
    expected_data_queue = []
    
    # --- Automated Test Sequence ---
    NUM_TRANSACTIONS = 50 # Run 50 random operations

    for i in range(NUM_TRANSACTIONS):
        # Decide randomly whether to attempt a write or a read
        action = random.choice(["write", "read"])

        if action == "write":
            # Generate random 32-bit data (0x00000000 to 0xFFFFFFFF)
            data_to_write = random.getrandbits(32)
            
            # Use our abstracted function
            await write_fifo(dut, data_to_write)
            
            # Record what we wrote into our scoreboard
            expected_data_queue.append(data_to_write)
            cocotb.log.info(f"TID {i}: Wrote 0x{data_to_write:08X}")
            
        elif action == "read" and expected_data_queue:
            # Only attempt a read if the queue isn't empty

            # Use our abstracted function
            actual_read_data_obj = await read_fifo(dut)
            
            # Check the output against our expected value
            expected_read_data = expected_data_queue.pop(0)
            
            # Convert the cocotb object to a standard Python integer for comparison and logging
            actual_read_data_int = actual_read_data_obj.to_unsigned()

            assert actual_read_data_int == expected_read_data, \
                f"TID {i}: Read mismatch! Expected 0x{expected_read_data:08X}, got 0x{actual_read_data_int:08X}"
            
            cocotb.log.info(f"TID {i}: Read and Verified 0x{actual_read_data_int:08X}")
        else:
            # If we randomly chose 'read' but the FIFO was empty, do nothing for this cycle
            await RisingEdge(dut.clk_i)

    cocotb.log.info("Test finished successfully!")