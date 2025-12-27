# test_fifo2.py
import cocotb
from cocotb.triggers import FallingEdge, RisingEdge, Timer

async def generate_clock(dut):
  """Generate clock pulses."""

  for _ in range(11):
    dut.clk_i.value = 0
    await Timer(1, unit="ns")
    dut.clk_i.value = 1
    await Timer(1, unit="ns")

@cocotb.test()
async def test_fifo2(dut):
  
  # Cycle 1
  cocotb.start_soon(generate_clock(dut))
  cocotb.log.info("----------------")
  
  dut.rst_i.value = 1
  
  # Cycle 2
  await Timer(1, unit="ns")
  await RisingEdge(dut.clk_i)  
  cocotb.log.info("clk_i is %s", dut.clk_i.value)
  cocotb.log.info("rst_i is %s", dut.rst_i.value)
  cocotb.log.info("rd_ptr is 0x%X", dut.rd_ptr.value)
  cocotb.log.info("wr_ptr is 0x%X", dut.wr_ptr.value)
  cocotb.log.info("rd_data_o is 0x%X", dut.rd_data_o.value)
  cocotb.log.info("----------------")
  
  
  dut.rst_i.value = 0
  
  # Cycle 3
  await Timer(1, unit="ns")  
  await RisingEdge(dut.clk_i)  
  cocotb.log.info("clk_i is %s", dut.clk_i.value)
  cocotb.log.info("wr_en_i is %s", dut.wr_en_i.value)
  cocotb.log.info("wr_data_i is 0x%X", dut.wr_data_i.value)
  cocotb.log.info("wr_ptr is 0x%X", dut.wr_ptr.value)
  cocotb.log.info("rd_data_o is 0x%X", dut.rd_data_o.value)
  cocotb.log.info("----------------")
  
  dut.wr_en_i.value = 1
  dut.wr_data_i.value = 0xA5A5A5A5
  
  # Cycle 4
  await Timer(1, unit="ns")
  await RisingEdge(dut.clk_i)  
  cocotb.log.info("clk_i is %s", dut.clk_i.value)
  cocotb.log.info("wr_en_i is %s", dut.wr_en_i.value)
  cocotb.log.info("wr_data_i is 0x%X", dut.wr_data_i.value)
  cocotb.log.info("wr_ptr is 0x%X", dut.wr_ptr.value)
  for i in range(dut.Depth.value.to_unsigned()):
    cocotb.log.info("mem[%d] is 0x%X", i, dut.mem[i].value)
  cocotb.log.info("----------------")
    
  dut.wr_en_i.value = 0
  dut.wr_data_i.value = 0x00000000
  
  # Cycle 5
  await Timer(1, unit="ns")
  await RisingEdge(dut.clk_i)
  cocotb.log.info("clk_i is %s", dut.clk_i.value)
  cocotb.log.info("wr_en_i is %s", dut.wr_en_i.value)
  cocotb.log.info("wr_data_i is 0x%X", dut.wr_data_i.value)
  cocotb.log.info("wr_ptr is 0x%X", dut.wr_ptr.value)
  for i in range(dut.Depth.value.to_unsigned()):
    cocotb.log.info("mem[%d] is 0x%X", i, dut.mem[i].value)
  cocotb.log.info("----------------")
  
  dut.wr_en_i.value = 1
  dut.wr_data_i.value = 0xFFFFFFFF
  
  
  # Cycle 5
  await Timer(1, unit="ns")
  await RisingEdge(dut.clk_i)  
  cocotb.log.info("clk_i is %s", dut.clk_i.value)
  cocotb.log.info("wr_en_i is %s", dut.wr_en_i.value)
  cocotb.log.info("wr_data_i is 0x%X", dut.wr_data_i.value)
  cocotb.log.info("wr_ptr is 0x%X", dut.wr_ptr.value)
  for i in range(dut.Depth.value.to_unsigned()):
    cocotb.log.info("mem[%d] is 0x%X", i, dut.mem[i].value)
  cocotb.log.info("----------------")
  
  dut.wr_en_i.value = 0
  dut.wr_data_i.value = 0x00000000
  
  # Cycle 5
  await Timer(1, unit="ns")
  await RisingEdge(dut.clk_i)  
  cocotb.log.info("clk_i is %s", dut.clk_i.value)
  cocotb.log.info("wr_en_i is %s", dut.wr_en_i.value)
  cocotb.log.info("wr_data_i is 0x%X", dut.wr_data_i.value)
  cocotb.log.info("wr_ptr is 0x%X", dut.wr_ptr.value)
  cocotb.log.info("rd_en_i is %s", dut.rd_en_i.value)
  cocotb.log.info("rd_ptr is 0x%X", dut.rd_ptr.value)
  cocotb.log.info("rd_data_o is 0x%X", dut.rd_data_o.value)
  for i in range(dut.Depth.value.to_unsigned()):
    cocotb.log.info("mem[%d] is 0x%X", i, dut.mem[i].value)
  cocotb.log.info("----------------")
  
  dut.rd_en_i.value = 1
  
  # Cycle 6
  await Timer(1, unit="ns")
  await RisingEdge(dut.clk_i)  
  cocotb.log.info("clk_i is %s", dut.clk_i.value)
  cocotb.log.info("wr_en_i is %s", dut.wr_en_i.value)
  cocotb.log.info("wr_data_i is 0x%X", dut.wr_data_i.value)
  cocotb.log.info("wr_ptr is 0x%X", dut.wr_ptr.value)
  cocotb.log.info("rd_en_i is %s", dut.rd_en_i.value)
  cocotb.log.info("rd_ptr is 0x%X", dut.rd_ptr.value)
  cocotb.log.info("rd_data_o is 0x%X", dut.rd_data_o.value)
  for i in range(dut.Depth.value.to_unsigned()):
    cocotb.log.info("mem[%d] is 0x%X", i, dut.mem[i].value)
  cocotb.log.info("----------------")
  
  dut.rd_en_i.value = 0
  
  # Cycle 7
  await Timer(1, unit="ns")
  await RisingEdge(dut.clk_i)  
  cocotb.log.info("clk_i is %s", dut.clk_i.value)
  cocotb.log.info("wr_en_i is %s", dut.wr_en_i.value)
  cocotb.log.info("wr_data_i is 0x%X", dut.wr_data_i.value)
  cocotb.log.info("wr_ptr is 0x%X", dut.wr_ptr.value)
  cocotb.log.info("rd_en_i is %s", dut.rd_en_i.value)
  cocotb.log.info("rd_ptr is 0x%X", dut.rd_ptr.value)
  cocotb.log.info("rd_data_o is 0x%X", dut.rd_data_o.value)
  for i in range(dut.Depth.value.to_unsigned()):
    cocotb.log.info("mem[%d] is 0x%X", i, dut.mem[i].value)
  cocotb.log.info("----------------")
  
  dut.rd_en_i.value = 1
  
  # Cycle 8
  await Timer(1, unit="ns")
  await RisingEdge(dut.clk_i)  
  cocotb.log.info("clk_i is %s", dut.clk_i.value)
  cocotb.log.info("wr_en_i is %s", dut.wr_en_i.value)
  cocotb.log.info("wr_data_i is 0x%X", dut.wr_data_i.value)
  cocotb.log.info("wr_ptr is 0x%X", dut.wr_ptr.value)
  cocotb.log.info("rd_en_i is %s", dut.rd_en_i.value)
  cocotb.log.info("rd_ptr is 0x%X", dut.rd_ptr.value)
  cocotb.log.info("rd_data_o is 0x%X", dut.rd_data_o.value)
  for i in range(dut.Depth.value.to_unsigned()):
    cocotb.log.info("mem[%d] is 0x%X", i, dut.mem[i].value)
  cocotb.log.info("----------------")
  
  dut.rd_en_i.value = 0
  
  # Cycle 9
  await Timer(1, unit="ns")
  await RisingEdge(dut.clk_i)  
  cocotb.log.info("clk_i is %s", dut.clk_i.value)
  cocotb.log.info("wr_en_i is %s", dut.wr_en_i.value)
  cocotb.log.info("wr_data_i is 0x%X", dut.wr_data_i.value)
  cocotb.log.info("wr_ptr is 0x%X", dut.wr_ptr.value)
  cocotb.log.info("rd_en_i is %s", dut.rd_en_i.value)
  cocotb.log.info("rd_ptr is 0x%X", dut.rd_ptr.value)
  cocotb.log.info("rd_data_o is 0x%X", dut.rd_data_o.value)
  for i in range(dut.Depth.value.to_unsigned()):
    cocotb.log.info("mem[%d] is 0x%X", i, dut.mem[i].value)
  cocotb.log.info("----------------")
  
  # Cycle 10
  await Timer(1, unit="ns")
  await RisingEdge(dut.clk_i)  
  cocotb.log.info("clk_i is %s", dut.clk_i.value)
  cocotb.log.info("wr_en_i is %s", dut.wr_en_i.value)
  cocotb.log.info("wr_data_i is 0x%X", dut.wr_data_i.value)
  cocotb.log.info("wr_ptr is 0x%X", dut.wr_ptr.value)
  cocotb.log.info("rd_en_i is %s", dut.rd_en_i.value)
  cocotb.log.info("rd_ptr is 0x%X", dut.rd_ptr.value)
  cocotb.log.info("rd_data_o is 0x%X", dut.rd_data_o.value)
  for i in range(dut.Depth.value.to_unsigned()):
    cocotb.log.info("mem[%d] is 0x%X", i, dut.mem[i].value)
  cocotb.log.info("----------------")
  