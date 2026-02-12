module bus_fabric_top #(
  parameter int unsigned AddressWidth = 32,
  parameter int unsigned DataWidth    = 32,
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
  output logic [1:0]             core_r_resp,

  // --------------------------------
  // Target-side pins (2 targets here)
  // target0_* and target1_*
  // --------------------------------

  // target0 -> fabric (ready/resp/data)
  input  logic                   t0_aw_ready,
  input  logic                   t0_w_ready,
  input  logic                   t0_b_valid,
  input  logic [1:0]             t0_b_resp,
  input  logic                   t0_ar_ready,
  input  logic                   t0_r_valid,
  input  logic [DataWidth-1:0]   t0_r_data,
  input  logic [1:0]             t0_r_resp,

  // fabric -> target0 (valid/addr/data)
  output logic                   t0_aw_valid,
  output logic [AddressWidth-1:0] t0_aw_addr,
  output logic                   t0_w_valid,
  output logic [DataWidth-1:0]   t0_w_data,
  output logic [StrobeWidth-1:0] t0_w_strb,
  output logic                   t0_b_ready,
  output logic                   t0_ar_valid,
  output logic [AddressWidth-1:0] t0_ar_addr,
  output logic                   t0_r_ready,

  // target1 -> fabric
  input  logic                   t1_aw_ready,
  input  logic                   t1_w_ready,
  input  logic                   t1_b_valid,
  input  logic [1:0]             t1_b_resp,
  input  logic                   t1_ar_ready,
  input  logic                   t1_r_valid,
  input  logic [DataWidth-1:0]   t1_r_data,
  input  logic [1:0]             t1_r_resp,

  // fabric -> target1
  output logic                   t1_aw_valid,
  output logic [AddressWidth-1:0] t1_aw_addr,
  output logic                   t1_w_valid,
  output logic [DataWidth-1:0]   t1_w_data,
  output logic [StrobeWidth-1:0] t1_w_strb,
  output logic                   t1_b_ready,
  output logic                   t1_ar_valid,
  output logic [AddressWidth-1:0] t1_ar_addr,
  output logic                   t1_r_ready
);

  // Instantiate interfaces internally (Verilator likes this)
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

  // ---- Target0 pins <-> target_ifs[0] ----
  always_comb begin
    // target0 -> fabric
    target_ifs[0].aw_ready = t0_aw_ready;
    target_ifs[0].w_ready  = t0_w_ready;
    target_ifs[0].b_valid  = t0_b_valid;
    target_ifs[0].b_resp   = t0_b_resp;
    target_ifs[0].ar_ready = t0_ar_ready;
    target_ifs[0].r_valid  = t0_r_valid;
    target_ifs[0].r_data   = t0_r_data;
    target_ifs[0].r_resp   = t0_r_resp;

    // fabric -> target0
    t0_aw_valid       = target_ifs[0].aw_valid;
    t0_aw_addr        = target_ifs[0].aw_addr;
    t0_w_valid        = target_ifs[0].w_valid;
    t0_w_data         = target_ifs[0].w_data;
    t0_w_strb         = target_ifs[0].w_strb;
    t0_b_ready        = target_ifs[0].b_ready;
    t0_ar_valid       = target_ifs[0].ar_valid;
    t0_ar_addr        = target_ifs[0].ar_addr;
    t0_r_ready        = target_ifs[0].r_ready;
  end

  // ---- Target1 pins <-> target_ifs[1] ----
  always_comb begin
    // target1 -> fabric
    target_ifs[1].aw_ready = t1_aw_ready;
    target_ifs[1].w_ready  = t1_w_ready;
    target_ifs[1].b_valid  = t1_b_valid;
    target_ifs[1].b_resp   = t1_b_resp;
    target_ifs[1].ar_ready = t1_ar_ready;
    target_ifs[1].r_valid  = t1_r_valid;
    target_ifs[1].r_data   = t1_r_data;
    target_ifs[1].r_resp   = t1_r_resp;
  
    // fabric -> target1
    t1_aw_valid       = target_ifs[1].aw_valid;
    t1_aw_addr        = target_ifs[1].aw_addr;
    t1_w_valid        = target_ifs[1].w_valid;
    t1_w_data         = target_ifs[1].w_data;
    t1_w_strb         = target_ifs[1].w_strb;
    t1_b_ready        = target_ifs[1].b_ready;
    t1_ar_valid       = target_ifs[1].ar_valid;
    t1_ar_addr        = target_ifs[1].ar_addr;
    t1_r_ready        = target_ifs[1].r_ready;
  end

  // Instantiate your real fabric (interfaces stay internal)
  bus_fabric #(
    .AddressWidth(AddressWidth),
    .DataWidth(DataWidth)
  ) u_fabric (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .core_if(core_if),
    .target_ifs(target_ifs)
  );

endmodule
