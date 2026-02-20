import random
import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock


async def reset(dut):
    cocotb.log.info("Resetting DUT")
    dut.rst_i.value = 1
    dut.core_aw_valid.value = 0
    dut.core_w_valid.value  = 0
    dut.core_b_ready.value  = 0
    dut.core_ar_valid.value = 0
    dut.core_r_ready.value  = 0
    await Timer(20, unit="ns")
    dut.rst_i.value = 0
    await RisingEdge(dut.clk_i)
    cocotb.log.info("Reset complete")



async def bus_write(dut, addr, strb, data):
    cocotb.log.info(f"WRITE addr=0x{addr:08X} data=0x{data:08X}")
# Address
    dut.core_aw_addr.value  = addr
    dut.core_aw_valid.value = 1

    # Wait for AW handshake
    while not (dut.core_aw_valid.value and dut.core_aw_ready.value):
        await RisingEdge(dut.clk_i)
    cocotb.log.info("AW handshake complete")

    dut.core_aw_valid.value = 0
    
# Data
    dut.core_w_data.value  = data
    dut.core_w_strb.value  = strb
    dut.core_w_valid.value = 1
    
    # Wait for W handshake
    while not (dut.core_w_valid.value and dut.core_w_ready.value):
        await RisingEdge(dut.clk_i)
    cocotb.log.info("W handshake complete")

    dut.core_w_valid.value = 0
    
# Response
    dut.core_b_ready.value = 1
    
    # Wait for response
    while not (dut.core_b_ready.value and dut.core_b_valid.value):
        await RisingEdge(dut.clk_i)
    cocotb.log.info("B handshake complete")

    dut.core_b_ready.value = 0
    await RisingEdge(dut.clk_i)


async def bus_read(dut, addr):
    cocotb.log.info(f"READ addr=0x{addr:08X}")
# Address
    dut.core_ar_addr.value  = addr
    dut.core_ar_valid.value = 1
    
    # Wait for AR handshake
    while not (dut.core_ar_valid.value and dut.core_ar_ready.value):
        await RisingEdge(dut.clk_i)
    cocotb.log.info("AR handshake complete")

    dut.core_ar_valid.value = 0
    
# Data
    dut.core_r_ready.value  = 1

    # Wait for R handshake
    while not dut.core_r_valid.value:
        await RisingEdge(dut.clk_i)
    cocotb.log.info("R handshake complete")

    dut.core_r_ready.value = 0
    data = int(dut.core_r_data.value)

    cocotb.log.info(f"R response received data=0x{data:08X}")

    await RisingEdge(dut.clk_i)
    
    return data

@cocotb.test()
async def test_basic_randomized(dut):
    cocotb.log.info("Starting bus_fabric basic randomized test")
    
    cocotb.start_soon(Clock(dut.clk_i, 10, unit="ns").start())
    
    await reset(dut)

    scoreboard = {}

    for _ in range(50):
        addr = random.randint(0, 511) * 4
        data = random.getrandbits(32)
        scoreboard[addr] = data
        
        await bus_write(dut, addr, 0xF, data)

    for addr, expected_data in scoreboard.items():
        actual_data = await bus_read(dut, addr)
        assert actual_data == expected_data, f"Mismatch at {hex(addr)}"
