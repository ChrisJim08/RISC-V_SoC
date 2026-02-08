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
    await Timer(20, units="ns")
    dut.rst_i.value = 0
    await RisingEdge(dut.clk_i)
    cocotb.log.info("Reset complete")



async def axi_write(dut, addr, data):
    cocotb.log.info(f"WRITE addr=0x{addr:08X} data=0x{data:08X}")
    # Address
    dut.core_aw_addr.value  = addr
    dut.core_aw_valid.value = 1

    
    dut.t0_aw_ready.value = 1

    # Wait for AW handshake
    while not (dut.core_aw_valid.value and dut.core_aw_ready.value):
        await RisingEdge(dut.clk_i)
    cocotb.log.info("AW handshake complete")

    # Data
    dut.core_w_data.value  = data
    dut.core_w_strb.value  = 0xF
    dut.core_w_valid.value = 1
    dut.core_b_ready.value = 1
    
    # Wait for W handshake
    while not (dut.core_w_valid.value and dut.core_w_ready.value):
        await RisingEdge(dut.clk_i)

        resp = int(dut.t0_w_ready.value)
        cocotb.log.info(f"core_w_ready={resp}")
        dut.t0_w_ready.value = 1
        
    cocotb.log.info("W handshake complete")

    dut.core_aw_valid.value = 0
    dut.core_w_valid.value  = 0

    dut.t0_aw_ready.value = 0
    dut.t0_w_ready.value = 0
    dut.t0_b_valid.value = 1
    
    # Wait for response
    while not dut.core_b_valid.value:
        await RisingEdge(dut.clk_i)

    resp = int(dut.core_b_resp.value)
    cocotb.log.info(f"B response received resp={resp}")

    assert resp == 0, "Write response error"

    dut.core_b_ready.value = 0
    await RisingEdge(dut.clk_i)


async def axi_read(dut, addr):
    cocotb.log.info(f"READ addr=0x{addr:08X}")
    dut.core_ar_addr.value  = addr
    dut.core_ar_valid.value = 1
    dut.core_r_ready.value  = 1
    
    dut.t0_ar_ready.value = 1
    
    # Wait for AR handshake
    while not (dut.core_ar_valid.value and dut.core_ar_ready.value):
        await RisingEdge(dut.clk_i)
    cocotb.log.info("AR handshake complete")

    dut.core_ar_valid.value = 0
    
    dut.t0_ar_ready.value = 0

    # Wait for R
    while not dut.core_r_valid.value:
        await RisingEdge(dut.clk_i)

    data = int(dut.core_r_data.value)
    resp = int(dut.core_r_resp.value)

    cocotb.log.info(
        f"R response received data=0x{data:08X} resp={resp}"
    )

    assert resp == 0, "Read response error"

    dut.core_r_ready.value = 0
    await RisingEdge(dut.clk_i)

    return data


@cocotb.test()
async def test_bus(dut):
    cocotb.log.info("Starting bus_fabric basic test")

    cocotb.start_soon(Clock(dut.clk_i, 10, units="ns").start())

    await reset(dut)

    test_addr = 0x0000_0010
    test_data = 0xDEADBEEF

    await axi_write(dut, test_addr, test_data)
    readback = await axi_read(dut, test_addr)
    
    cocotb.log.info(
        f"Readback check: got=0x{readback:08X} expected=0x{test_data:08X}"
    )

    assert readback == test_data
    
    cocotb.log.info("Basic write/read test PASSED")
