module bus_fabric_top #(
  localparam int unsigned AddressWidth = 32,
  localparam int unsigned DataWidth    = 32,
  localparam int unsigned StrobeWidth = DataWidth/8,
  localparam int unsigned NumTargets  = 2
)(
  input  logic clk_i,
  input  logic rst_i,

  // -------------------------
  // Core-side (initiator) pins
  // -------------------------
  input  logic                   core_aw_valid,
  output logic                   core_aw_ready,
  input  logic [AddressWidth-1:0] core_aw_addr,

  input  logic                   core_w_valid,
  output logic                   core_w_ready,
  input  logic [DataWidth-1:0]   core_w_data,
  input  logic [StrobeWidth-1:0] core_w_strb,

  output logic                   core_b_valid,
  input  logic                   core_b_ready,
  output logic [1:0]             core_b_resp,

  input  logic                   core_ar_valid,
  output logic                   core_ar_ready,
  input  logic [AddressWidth-1:0] core_ar_addr,

  output logic                   core_r_valid,
  input  logic                   core_r_ready,
  output logic [DataWidth-1:0]   core_r_data,
  output logic [1:0]             core_r_resp
);

  // Instantiate interfaces internally
  bus_if #(.AddressWidth(AddressWidth), .DataWidth(DataWidth)) core_if();
  bus_if #(.AddressWidth(AddressWidth), .DataWidth(DataWidth)) target_ifs[NumTargets]();

  // ---- Core pins <-> core_if ----
  always_comb begin
    core_if.aw_valid = core_aw_valid;
    core_if.aw_addr  = core_aw_addr;
    core_aw_ready    = core_if.aw_ready;

    core_if.w_valid  = core_w_valid;
    core_if.w_data   = core_w_data;
    core_if.w_strb   = core_w_strb;
    core_w_ready     = core_if.w_ready;

    core_b_valid     = core_if.b_valid;
    core_b_resp      = core_if.b_resp;
    core_if.b_ready  = core_b_ready;

    core_if.ar_valid = core_ar_valid;
    core_if.ar_addr  = core_ar_addr;
    core_ar_ready    = core_if.ar_ready;

    core_r_valid     = core_if.r_valid;
    core_r_data      = core_if.r_data;
    core_r_resp      = core_if.r_resp;
    core_if.r_ready  = core_r_ready;
  end

  // Instantiate fabric
  bus_fabric #(
    .AddressWidth(AddressWidth),
    .DataWidth(DataWidth)
  ) fabric (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .core_if(core_if),
    .target_ifs(target_ifs)
  );

  logic                    mem_wr_en;
  logic [NumBytes-1:0]     mem_byte_en;
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
