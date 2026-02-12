//  Module: bus_fabric
//
module bus_fabric #(
  parameter  int unsigned AddressWidth = 32,
  parameter  int unsigned DataWidth    = 32,
  parameter  int unsigned NumTargets   = 2,
  localparam int unsigned StrobeWidth  = DataWidth / 8
)( 
  input logic clk_i,
  input logic rst_i,
  bus_if.fabric_to_initiator core_if,
  bus_if.fabric_to_target    target_ifs [NumTargets]
);

// Status flags
  logic aw_hs_seen, w_hs_seen; 
  logic wr_inflight, rd_inflight;

// Handshake flags
  logic aw_handshake, core_w_handshake, target_w_handshake, b_handshake;
  logic ar_handshake, r_handshake;

// Write buffer
  logic skid_full;
  logic skid_w_ready;
  logic [DataWidth-1:0]   skid_data;
  logic [StrobeWidth-1:0] skid_strb;

// One-hot select lines
  logic [NumTargets-1:0] wr_sel_onehot_d;
  logic [NumTargets-1:0] wr_sel_onehot_q;
  logic [NumTargets-1:0] wr_sel_onehot;
  logic [NumTargets-1:0] rd_sel_onehot_d;
  logic [NumTargets-1:0] rd_sel_onehot_q;
  logic [NumTargets-1:0] rd_sel_onehot;

// Routing arrays
  logic [NumTargets-1:0] aw_ready_from_tgt;
  logic [NumTargets-1:0] w_ready_from_tgt;
  logic [NumTargets-1:0] w_valid_from_tgt;
  logic [NumTargets-1:0] b_valid_from_tgt;
  logic [NumTargets-1:0][1:0] b_resp_from_tgt;

  logic [NumTargets-1:0] ar_ready_from_tgt;
  logic [NumTargets-1:0] r_valid_from_tgt;
  logic [NumTargets-1:0][DataWidth-1:0] r_data_from_tgt;
  logic [NumTargets-1:0][1:0] r_resp_from_tgt;

// Selected target signals
  logic sel_target_if_w_valid;
  logic sel_target_if_w_ready;

// Handshake flags
  // Write address (AW)
  assign aw_handshake = core_if.aw_valid && core_if.aw_ready;

  // Write data (W)
  assign core_w_handshake   = core_if.aw_valid  && core_if.aw_ready;
  assign target_w_handshake = sel_target_if_w_valid && sel_target_if_w_ready;

  // Write response (B)
  assign b_handshake = core_if.b_ready && core_if.b_valid;           
  
  // Read address (AR)
  assign ar_handshake = core_if.ar_valid && core_if.ar_ready;
  
  // Read data (R)
  assign r_handshake = core_if.r_ready && core_if.r_valid;

// In-flight flag
  assign wr_inflight = aw_hs_seen && w_hs_seen;

// Bypass MUX for target select signal latching while transaction is in-flight
  assign wr_sel_onehot = aw_hs_seen  ? wr_sel_onehot_q : wr_sel_onehot_d;
  assign rd_sel_onehot = rd_inflight ? rd_sel_onehot_q : rd_sel_onehot_d;

// Skid W ready flag
  assign skid_w_ready = !skid_full;

// Latching logic
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      aw_hs_seen <= 1'b0;
      w_hs_seen  <= 1'b0;
      rd_inflight <= 1'b0;
      wr_sel_onehot_q <= '0;
      rd_sel_onehot_q <= '0;

      skid_data <= '0;
      skid_strb <= '0;
      skid_full <= 1'b0;

    end else begin
  // Write channels
    // Lock target
      if (aw_handshake && !aw_hs_seen) begin
        aw_hs_seen <= 1'b1;
                
        wr_sel_onehot_q <= wr_sel_onehot_d;
      end

    // When target is needed but not ready, buffer data if space
      if (core_w_handshake && !sel_target_if_w_ready) begin
        skid_data  <= core_if.w_data;
        skid_strb  <= core_if.w_strb;
        skid_full  <= 1'b1;
      end

    // Target accepted data
      if (target_w_handshake && !w_hs_seen) begin
        w_hs_seen <= 1'b1;
        skid_data <= '0;
        skid_strb <= '0;
        skid_full <= 1'b0;
      end

    // Response (transaction finished)
      if (b_handshake && wr_inflight) begin
        aw_hs_seen <= 1'b0;
        w_hs_seen  <= 1'b0;

        wr_sel_onehot_q <= '0;                          
      end

  // Read channels
    // Lock target
      if (ar_handshake && !rd_inflight) begin
        rd_inflight  <= 1'b1;

        rd_sel_onehot_q <= rd_sel_onehot_d;
      end
    // Handshake (transaction finished)
      if (r_handshake && rd_inflight) begin
        rd_inflight     <= 1'b0;
        rd_sel_onehot_q <= '0;
      end
    end
  end

// Side routing for handshake logic using an array (Verilator workaround)
  always_comb begin
    for (int i = 0; i < NumTargets; i++) begin
      sel_target_if_w_valid  = wr_sel_onehot[i] ? w_valid_from_tgt[i]  : 1'b0;
      sel_target_if_w_ready  = wr_sel_onehot[i] ? w_ready_from_tgt[i]  : 1'b0;
    end
  end

// Bus generate block 
  genvar g;
  generate
    for (g = 0; g < NumTargets; g++) begin
  // Routing array logic
    // Write channels
      assign aw_ready_from_tgt[g] = target_ifs[g].aw_ready;
      assign w_ready_from_tgt[g]  = target_ifs[g].w_ready;
      assign w_valid_from_tgt[g]  = target_ifs[g].w_valid;
      assign b_valid_from_tgt[g]  = target_ifs[g].b_valid;
      assign b_resp_from_tgt[g]   = target_ifs[g].b_resp;
    // Read channels
      assign ar_ready_from_tgt[g] = target_ifs[g].ar_ready;
      assign r_valid_from_tgt[g]  = target_ifs[g].r_valid;
      assign r_data_from_tgt[g]   = target_ifs[g].r_data;
      assign r_resp_from_tgt[g]   = target_ifs[g].r_resp;

  // Forward routing
      always_comb begin : target_demux
    // Defaults
        target_ifs[g].aw_valid = 1'b0;
        target_ifs[g].aw_addr  = '0;
        target_ifs[g].w_valid  = 1'b0;
        target_ifs[g].w_data   = '0;
        target_ifs[g].w_strb   = '0;
        target_ifs[g].b_ready  = 1'b0;
        target_ifs[g].ar_valid = 1'b0;
        target_ifs[g].ar_addr  = '0;
        target_ifs[g].r_ready  = 1'b0;

    // Routing
      // Write channels
        if (wr_sel_onehot[g]) begin
          target_ifs[g].aw_valid = core_if.aw_valid;
          target_ifs[g].aw_addr  = core_if.aw_addr;
          target_ifs[g].w_valid  = skid_full ? 1'b1      : core_if.w_valid; 
          target_ifs[g].w_data   = skid_full ? skid_data : core_if.w_data;  
          target_ifs[g].w_strb   = skid_full ? skid_strb : core_if.w_strb;  
          target_ifs[g].b_ready  = core_if.b_ready;
        end

      // Read channels
        if (rd_sel_onehot[g]) begin
          target_ifs[g].ar_valid = core_if.ar_valid;
          target_ifs[g].ar_addr  = core_if.ar_addr;
          target_ifs[g].r_ready  = core_if.r_ready;
        end
      end // end of target_demux
    end
  endgenerate
  
// Backward routings
  always_comb begin : initiator_mux
  // Defaults
    core_if.aw_ready = 1'b0;  
    core_if.w_ready  = skid_w_ready;
    core_if.b_valid  = 1'b0;
    core_if.b_resp   = '0;
    core_if.ar_ready = 1'b0;
    core_if.r_valid = 1'b0;
    core_if.r_data = '0;
    core_if.r_resp = '0;
  
  // Routing
    for (int i = 0; i < NumTargets; i++) begin
    // Write channels
      if (wr_sel_onehot[i]) begin
        core_if.w_ready = w_ready_from_tgt[i];
        core_if.aw_ready = aw_ready_from_tgt[i];
        core_if.b_valid  = b_valid_from_tgt[i];
        core_if.b_resp   = b_resp_from_tgt[i];
      end 

    // Read channels
      if (rd_sel_onehot[i]) begin
        core_if.ar_ready = ar_ready_from_tgt[i];
        core_if.r_valid = r_valid_from_tgt[i];
        core_if.r_data = r_data_from_tgt[i];
        core_if.r_resp = r_resp_from_tgt[i];
      end
    end
  end // initiator_mux

  bus_addr_decode #(
    .AddressWidth(AddressWidth),
    .NumTargets(NumTargets)
  ) write_decoder (
    .valid_i(core_if.aw_valid),
    .addr_i(core_if.aw_addr),
    .addr_hit_o(),                  // Implement addr_hit validation TODO
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
