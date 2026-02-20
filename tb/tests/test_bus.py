import random
import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock


async def reset(dut):
    cocotb.log.info("Resetting DUT")
    dut.rst_i.value = 1
    dut.core_if.aw_valid.value = 0
    dut.core_if.w_valid.value  = 0
    dut.core_if.b_ready.value  = 0
    dut.core_if.ar_valid.value = 0
    dut.core_if.r_ready.value  = 0
    await Timer(20, unit="ns")
    dut.rst_i.value = 0
    await RisingEdge(dut.clk_i)
    cocotb.log.info("Reset complete")



async def bus_write(dut, addr, strb, data):
    cocotb.log.info(f"WRITE addr=0x{addr:08X} data=0x{data:08X}")
# Address
    dut.core_if.aw_addr.value  = addr
    dut.core_if.aw_valid.value = 1

    # Wait for AW handshake
    while not (dut.core_if.aw_valid.value and dut.core_if.aw_ready.value):
        await RisingEdge(dut.clk_i)
    cocotb.log.info("AW handshake complete")

    dut.core_if.aw_valid.value = 0
    
# Data
    dut.core_if.w_data.value  = data
    dut.core_if.w_strb.value  = strb
    dut.core_if.w_valid.value = 1
    
    # Wait for W handshake
    while not (dut.core_if.w_valid.value and dut.core_if.w_ready.value):
        await RisingEdge(dut.clk_i)
    cocotb.log.info("W handshake complete")

    dut.core_if.w_valid.value = 0
    
# Response
    dut.core_if.b_ready.value = 1
    
    # Wait for response
    while not (dut.core_if.b_ready.value and dut.core_if.b_valid.value):
        await RisingEdge(dut.clk_i)
    cocotb.log.info("B handshake complete")

    dut.core_if.b_ready.value = 0
    await RisingEdge(dut.clk_i)


async def bus_read(dut, addr):
    cocotb.log.info(f"READ addr=0x{addr:08X}")
# Address
    dut.core_if.ar_addr.value  = addr
    dut.core_if.ar_valid.value = 1
    
    # Wait for AR handshake
    while not (dut.core_if.ar_valid.value and dut.core_if.ar_ready.value):
        await RisingEdge(dut.clk_i)
    cocotb.log.info("AR handshake complete")

    dut.core_if.ar_valid.value = 0
    
# Data
    dut.core_if.r_ready.value  = 1

    # Wait for R handshake
    while not dut.core_if.r_valid.value:
        await RisingEdge(dut.clk_i)
    cocotb.log.info("R handshake complete")

    dut.core_if.r_ready.value = 0
    data = int(dut.core_if.r_data.value)

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
        
@cocotb.test()
async def test_w_before_aw(dut):
    cocotb.log.info("Starting bus_fabric w before aw test")
    
    cocotb.start_soon(Clock(dut.clk_i, 10, unit="ns").start())
    
    data = random.getrandbits(32)
    strb = 0xF
    
    cocotb.log.info(f"WRITE data = 0x{data:08X}")

# -- Write --
# Data
    dut.core_if.w_data.value  = data
    dut.core_if.w_strb.value  = strb
    dut.core_if.w_valid.value = 1
    
    # Wait for W handshake
    while not (dut.core_if.w_valid.value and dut.core_if.w_ready.value):
        await RisingEdge(dut.clk_i)
    cocotb.log.info("W handshake complete")

    dut.core_if.w_valid.value = 0
    
# Address
    addr = random.randint(0, 511) * 4
    
    dut.core_if.aw_addr.value  = addr
    dut.core_if.aw_valid.value = 1

    # Wait for AW handshake
    while not (dut.core_if.aw_valid.value and dut.core_if.aw_ready.value):
        await RisingEdge(dut.clk_i)
    cocotb.log.info("AW handshake complete")

    dut.core_if.aw_valid.value = 0
    
# Response
    dut.core_if.b_ready.value = 1
    
    # Wait for response
    while not (dut.core_if.b_ready.value and dut.core_if.b_valid.value):
        await RisingEdge(dut.clk_i)
    cocotb.log.info("B handshake complete")

    dut.core_if.b_ready.value = 0
    await RisingEdge(dut.clk_i)

    
# Memory check
#    cocotb.log.info(f"sel_target_if.w_ready = {dut.fabric.sel_target_if_w_ready.value}")
#    cocotb.log.info(f"skid_data = {int(dut.fabric.skid_data.value):08X}")
#    await RisingEdge(dut.clk_i)
#    cocotb.log.info(f"skid_data = {int(dut.fabric.skid_data.value):08X}")
#    await RisingEdge(dut.clk_i)
#    cocotb.log.info(f"skid_data = {int(dut.fabric.skid_data.value):08X}")
    
# -- Read --
    
    actual_data = await bus_read(dut, addr)
# Read
    assert actual_data == data, f"Mismatch at {hex(addr)}"
