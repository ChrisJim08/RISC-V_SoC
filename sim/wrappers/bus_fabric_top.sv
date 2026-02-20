module bus_fabric_top #(
  localparam int unsigned AddressWidth = 32,
  localparam int unsigned DataWidth    = 32,
  localparam int unsigned StrobeWidth = DataWidth/8,
  localparam int unsigned NumTargets  = 2
)(
  input  logic clk_i,
  input  logic rst_i
);

  // Instantiate interfaces internally
  bus_if #(.AddressWidth(AddressWidth), .DataWidth(DataWidth)) core_if();
  bus_if #(.AddressWidth(AddressWidth), .DataWidth(DataWidth)) target_ifs[NumTargets]();

  // Instantiate fabric
  bus_fabric #(
    .AddressWidth(AddressWidth),
    .DataWidth(DataWidth),
    .NumTargets(NumTargets)
  ) fabric (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .core_if(core_if),
    .target_ifs(target_ifs)
  );

  logic                    mem_wr_en;
  logic [StrobeWidth-1:0]  mem_byte_en;
  logic [AddressWidth-1:0] mem_addr;
  logic [DataWidth-1:0]    mem_wr_data;
  logic [DataWidth-1:0]    mem_r_data;

  ram_bus_adapter #(
    .AddressWidth(AddressWidth),
    .DataWidth(DataWidth)
  ) memory_bus_adapter (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .mem_wr_en_o(mem_wr_en),
    .mem_byte_en_o(mem_byte_en),
    .mem_addr_o(mem_addr),
    .mem_wr_data_o(mem_wr_data),
    .mem_r_data_i(mem_r_data),
    .bus_if(target_ifs[0])
  );

  mem #(
    .AddressWidth(AddressWidth),
    .DataWidth(DataWidth),
    .DepthWords(2048)
  ) memory (
    .clk_i(clk_i),
    .wr_en_i(mem_wr_en),
    .byte_en_i(mem_byte_en),
    .addr_i(mem_addr),
    .wr_data_i(mem_wr_data),
    .r_data_o(mem_r_data)
  );

endmodule
