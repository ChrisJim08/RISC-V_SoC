//  Module: bus_fabric
//
module bus_fabric #(
  parameter int unsigned AddressWidth = 32,
  parameter int unsigned DataWidth    = 32,
  parameter int unsigned NumTargets   = 2
)( 
  input logic clk_i,
  input logic rst_i,
  bus_if.initiator core_if,
  bus_if.target    target_ifs [NumTargets]
);

// Internal Signals

  // Status flags
  logic aw_seen, w_seen;
  logic write_busy;
  logic wr_inflight, rd_inflight; // TODO add/remove any (!)inflight validation?

  // Handshake flags
  logic aw_handshake, w_handshake, b_handshake, ar_handshake, r_handshake;

  // One-hot select lines
  logic [NumTargets-1:0] wr_sel_onehot_d;
  logic [NumTargets-1:0] wr_sel_onehot_q;
  logic [NumTargets-1:0] wr_sel_onehot;
  logic [NumTargets-1:0] rd_sel_onehot_d;
  logic [NumTargets-1:0] rd_sel_onehot_q;
  logic [NumTargets-1:0] rd_sel_onehot;

// Handshake flag logic
  // Write address (AW)
  assign aw_handshake = core_if.aw_valid && core_if.aw_ready;

  // Write data (W)

  assign w_handshake = core_if.w_ready && core_if.w_valid;
  
  // Write response (B)
  assign b_handshake = core_if.b_ready && core_if.b_valid;
  
  // Read address (AR)
  assign ar_handshake = core_if.ar_valid && core_if.ar_ready;
  
  // Read data (R)
  assign r_handshake = core_if.r_ready && core_if.r_valid;
  
// One-hot sel / Seen flag logic
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      aw_seen <= 1'b0;
      w_seen  <= 1'b0;
      rd_inflight <= 1'b0;
      wr_sel_onehot_q <= '0;
      rd_sel_onehot_q <= '0;

    end else begin
      if (aw_handshake) begin
        aw_seen <= 1'b1;
      end
      
      if (w_handshake) begin
        w_seen <= 1'b1;
        // if (!aw_seen) latch data and strobe
        // w_data_d <= core_if.w_data; 
      end
      
      if (b_handshake && wr_busy) begin
        aw_seen <= 1'b0;
        w_seen  <= 1'b0;
        wr_sel_onehot_q <= '0;
      end

      if (ar_handshake && !rd_inflight) begin
        rd_inflight  <= 1'b1;
      end
      
      if (r_handshake) begin
        rd_inflight <= 1'b0;
        rd_sel_onehot_q <= '0;
      end

    // Latch target during AW / AR handshake
      if (aw_handshake) begin
        wr_sel_onehot_q <= wr_sel_onehot_d;
      end
      if (ar_handshake) begin
        rd_sel_onehot_q <= rd_sel_onehot_d;
      end
    end
  end
  
  // Use latched selection while transaction is in-flight
  assign wr_sel_onehot = aw_seen ? wr_sel_onehot_q : wr_sel_onehot_d;
  assign rd_sel_onehot = rd_inflight ? rd_sel_onehot_q : rd_sel_onehot_d;

// In-flight / Busy flag logic
  assign wr_busy     = aw_seen && w_seen;
  assign wr_inflight = aw_seen || w_seen;

// Forward routing
  always_comb begin : target_demux
  // Defaults
    for (int i = 0; i < NumTargets; i++) begin
    // Write channels
      // AW
      target_ifs[i].aw_valid = 1'b0;
      target_ifs[i].aw_addr  = '0;
      // W
      target_ifs[i].w_valid = 1'b0;
      target_ifs[i].w_data  = '0;
      target_ifs[i].w_strb  = '0;
      // B
      target_ifs[i].b_ready = 1'b0;

    // Read channels
      // AR
      target_ifs[i].ar_valid = 1'b0;
      target_ifs[i].ar_addr  = '0;
      // R
      target_ifs[i].r_ready = 1'b0;
    end

  // Routing
    for (int i = 0; i < NumTargets; i++) begin 
    // Write channels
      if (wr_sel_onehot[i]) begin
      // AW
        if (!aw_seen) begin
          target_ifs[i].aw_valid = core_if.aw_valid;
          target_ifs[i].aw_addr  = core_if.aw_addr;
        end

      // W
        if (!w_seen) begin
          target_ifs[i].w_valid = core_if.w_valid;
          target_ifs[i].w_data  = core_if.w_data;
          target_ifs[i].w_strb  = core_if.w_strb;
        end 
      // B
        if (wr_busy) begin
          target_ifs[i].b_ready = core_if.b_ready;
        end
      end
       
    // Read channels
      if (rd_sel_onehot[i]) begin
      // AR
        if (!rd_inflight) begin
          target_ifs[i].ar_valid = core_if.ar_valid;
          target_ifs[i].ar_addr  = core_if.ar_addr;
        end

      // R
        target_ifs[i].r_ready = core_if.r_ready;
      end
    end
  end
  
// Backward routings
  always_comb begin : initiator_mux
  // Defaults
    // Write channels
    // AW
    core_if.aw_ready = 1'b0;
    // W
    core_if.w_ready = 1'b0;
    // B
    core_if.b_valid = 1'b0;
    core_if.b_resp = '0;

    // Read channels
    // AR
    core_if.ar_ready = 1'b0;
    // R
    core_if.r_valid = 1'b0;
    core_if.r_data = '0;
    core_if.r_resp = '0;

    for (int j = 0; j < NumTargets; j++) begin
    // Write channels
      if (wr_sel_onehot[j]) begin
      // AW
        core_if.aw_ready = aw_seen ? 1'b0 : target_ifs[j].aw_ready;
      // W
        core_if.w_ready  = w_seen ? 1'b0 : target_ifs[j].w_ready;
      // B
        core_if.b_valid  = target_ifs[j].b_valid;
        core_if.b_resp   = target_ifs[j].b_resp;
      end
      
    // Read channels
      if (rd_sel_onehot[j]) begin
      // AR
        core_if.ar_ready = rd_inflight ? 1'b0 : target_ifs[j].ar_ready;
      // R
        core_if.r_valid = target_ifs[j].r_valid;
        core_if.r_data = target_ifs[j].r_data;
        core_if.r_resp = target_ifs[j].r_resp;
      end
    end
  end

  bus_addr_decode #(
    .AddressWidth(AddressWidth),
    .NumTargets(NumTargets)
  ) write_decoder (
    .valid_i(core_if.aw_valid),
    .addr_i(core_if.aw_addr),
    .addr_hit_o(), // TODO implement addr_hit validation
    .sel_onehot_o(wr_sel_onehot_d)
  );

  bus_addr_decode #(
    .AddressWidth(AddressWidth),
    .NumTargets(NumTargets)
  ) read_decoder (
    .valid_i(core_if.ar_valid),
    .addr_i(core_if.ar_addr),
    .addr_hit_o(),
    .sel_onehot_o(rd_sel_onehot_d)
  );
  
endmodule
