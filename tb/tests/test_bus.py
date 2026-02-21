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
    
async def drive_aw(dut, addr):
    dut.core_if.aw_valid.value = 1
    dut.core_if.aw_addr.value  = addr
    await RisingEdge(dut.clk_i)
    while not dut.core_if.aw_ready.value:
        await RisingEdge(dut.clk_i)
    cocotb.log.info("AW handshake complete")
    dut.core_if.aw_valid.value = 0
    dut.core_if.aw_addr.value  = 0

async def drive_w(dut, data, strb):
    dut.core_if.w_data.value = data
    dut.core_if.w_strb.value = strb
    dut.core_if.w_valid.value = 1
    await RisingEdge(dut.clk_i)
    while not dut.core_if.w_ready.value:
        await RisingEdge(dut.clk_i)
    cocotb.log.info("W handshake complete")
    dut.core_if.w_valid.value = 0
    
async def drive_b(dut):
    dut.core_if.b_ready.value = 1
    while not (dut.core_if.b_valid.value):
        await RisingEdge(dut.clk_i)
    cocotb.log.info("B handshake complete")
    dut.core_if.b_ready.value = 0
    
async def drive_ar(dut, addr):
    dut.core_if.ar_addr.value  = addr
    dut.core_if.ar_valid.value = 1
    while not (dut.core_if.ar_ready.value):
        await RisingEdge(dut.clk_i)
    cocotb.log.info("AR handshake complete")
    dut.core_if.ar_valid.value = 0
    
async def drive_r(dut):
    dut.core_if.r_ready.value = 1
    while not dut.core_if.r_valid.value:
        await RisingEdge(dut.clk_i)
    cocotb.log.info("R handshake complete")
    dut.core_if.r_ready.value = 0

async def bus_write(dut, addr, strb, data):
    cocotb.log.info(f"WRITE addr=0x{addr:08X} data=0x{data:08X}")
  # Address
    await drive_aw(dut, addr)
  # Data
    await drive_w(dut, data, strb)
  # Response
    await drive_b(dut)   
    await RisingEdge(dut.clk_i)


async def bus_read(dut, addr):
    cocotb.log.info(f"READ addr=0x{addr:08X}")
  # Address
    await drive_ar(dut, addr)
  # Data
    await drive_r(dut)
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
    
    await reset(dut)
    
    addr = random.randint(0, 511) * 4
    data = random.getrandbits(32)
    strb = 0xF
    
# -- Write --
    cocotb.log.info(f"WRITE addr=0x{addr:08X} data = 0x{data:08X}")
    
  # Data
    await drive_w(dut, data, strb)
  # Address
    await drive_aw(dut, addr)
    
  # Response
    await drive_b(dut)
    
# -- Read --
    actual_data = await bus_read(dut, addr)
    
# -- Assertion --
    assert actual_data == data, f"Mismatch at {hex(addr)}"
