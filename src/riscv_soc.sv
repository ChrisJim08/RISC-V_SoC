//  Module: riscv_soc
//
module riscv_soc #(
  parameter int unsigned AddressWidth = 32,
  parameter int unsigned DataWidth    = 32,
  parameter int unsigned NumTargets   = 2
)(
  input  logic                    clk_i,
  input  logic                    rst_i, 
  input  logic                    imem_load_i, 
  input  logic [AddressWidth-1:0] imem_load_addr_i, 
  input  logic [DataWidth-1:0]    imem_load_data_i,
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
    .s_if(targets)
  );

  
  riscv_core #(
    .AddressWidth(AddressWidth),
    .DataWidth(DataWidth)
  ) riscv_core (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .instr_i(instr),
    .imem_addr_o(core_imem_addr),
    .dmem_r_data_i(dmem_r_data),
    .dmem_wr_en_o(dmem_wr_en),
    .dmem_addr_o(dmem_addr),
    .dmem_wr_data_o(dmem_wr_data),
    .halt_o(halt_o)
  );
endmodule
