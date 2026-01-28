//  Module: riscv_soc
//
module riscv_soc #(
  parameter int unsigned AddressWidth = 32,
  parameter int unsigned DataWidth    = 32,
  parameter int unsigned NumTargets   = 2
)(
  input  logic                    clk_i,
  input  logic                    rst_i, 

// Instruction memory ports
  input  logic [DataWidth-1:0]    instr_i,
  output logic [AddressWidth-1:0] core_imem_addr_o, 

// dmem (RAM) ports
  input  logic [DataWidth-1:0]    dmem_r_data_i,
  output logic                    dmem_wr_en_o,
  output logic [AddressWidth-1:0] dmem_addr_o,
  output logic [DataWidth-1:0]    dmem_wr_data_o,

// Simulation signal
  output logic                    halt_o  
);

// Core's bus interface
  bus_if.initiator core_if;

// Array of bus target interfaces
  bus_if.target target_ifs [NumTargets];

// Bus fabric
  bus_fabric #(
    .AddressWidth(AddressWidth),
    .DataWidth(DataWidth),
    .NumTargets(NumTargets)
  ) bus_fabric ( 
    .core_if(core_if),
    .s_if(target_ifs)
  );

// Core's bus adapter TODO

// SoC core
  riscv_core #(
    .AddressWidth(AddressWidth),
    .DataWidth(DataWidth)
  ) riscv_core (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .instr_i(instr_i),
    .imem_addr_o(core_imem_addr_o),
    .dmem_r_data_i(dmem_r_data_i),
    .dmem_wr_en_o(dmem_wr_en_o),
    .dmem_addr_o(dmem_addr_o),
    .dmem_wr_data_o(dmem_wr_data_o),
    .halt_o(halt_o)
  );

// dmem's (RAM) bus adapter TODO

endmodule
