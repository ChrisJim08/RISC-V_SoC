//  Module: bus_fabric
//
module bus_fabric #(
  parameter int unsigned AddressWidth = 32,
  parameter int unsigned DataWidth    = 32,
  parameter int unsigned NumTargets   = 2
)( 
  clk_i,
  rst_i,
  bus_if.initiator core_if,
  bus_if.target    target_ifs [NumTargets]
);

// Internal Signals

  // Status flags
  logic wr_inflight; // TODO add/remove any (!)wr_inflight validation?

  // Handshake flags
  logic aw_handshake, w_handshake, b_handshake;

  // One-hot select lines
  logic [NumTargets-1:0] sel_onehot_d;
  logic [NumTargets-1:0] sel_onehot_q;
  logic [NumTargets-1:0] sel_onehot;

// Handshake flag logic
  // Write address (AW)
  assign aw_handshake = core_if.aw_valid && core_if.aw_ready;

  // Write data (W)
  assign w_handshake = core_if.w_ready && core_if.w_valid;
  
  // Write response (B)
  assign b_handshake = core_if.b_ready && core_if.b_valid;
  
// One-hot sel / inflight logic
  always_ff @(posedge clk_i) begin
    // Latch target during AW handshake
    if (aw_handshake) begin
      wr_inflight  <= 1'b1;
      sel_onehot_q <= sel_onehot_d;
    end
    
    if (b_handshake) begin
      wr_inflight <= 1'b0;
    end
  end
  
  assign sel_onehot = wr_inflight ? sel_onehot_q : sel_onehot_d; 

// Write channels forward routing
  always_comb begin : req_demux
  // Defaults
    for (i = 0; i < NumTargets; i++) begin
    // AW channel
      target_ifs[i].aw_valid = 1'b0;
      target_ifs[i].aw_addr  = '0;

    // W channel
      target_ifs[i].w_valid  = 1'b0;
      target_ifs[i].w_data   = '0;
      target_ifs[i].w_strb   = '0;

    // B channel
      target_ifs[i].b_ready   = 1'b0;
    end

  // Selective routing
    for (i = 0; i < NumTargets; i++) begin 
      if (sel_onehot[i]) begin
      // Aw channel
        target_ifs[i].aw_valid = core_if.aw_valid && addr_hit;
        target_ifs[i].aw_addr  = core_if.aw_addr;
      
      // W channel
        target_ifs[i].w_valid = core_if.w_valid;
        target_ifs[i].w_data  = core_if.w_data;
        target_ifs[i].w_strb  = core_if.w_strb;
      
      // B channel
        target_ifs[i].b_ready = core_if.b_ready;
      end
    end
  end
  
// Forwards target's response to initiator
  always_comb begin : initiator_mux // Response-side mux TODO
    core_if.aw_ready = 1'b0;
    core_if.w_ready = 1'b0;
    core_if.b_valid = 1'b0;
    core_if.b_resp = '0;
    core_if.ar_ready = 1'b0;
    core_if.r_valid = 1'b0;
    core_if.r_data = '0;
    core_if.r_resp = '0;

    for (int j = 0; j < NumTargets; j++) begin
      if (sel_active[j]) begin
        core_if.aw_ready = target_ifs[j].aw_ready && addr_hit && !wr_inflight_q;
        core_if.w_ready  = target_ifs[j].w_ready;

        core_if.b_valid  = target_ifs[j].b_valid;
        core_if.b_resp   = target_ifs[j].b_resp;
      end
    end
  end

  bus_addr_decode #(
    .AddressWidth(AddressWidth),
    .NumTargets(NumTargets)
  ) addr_decoder (
    .valid_i(core_if.aw_valid),
    .addr_i(core_if.aw_addr),
    .sel_onehot_o(sel_onehot_d)
  );
  
endmodule
