//  Module: bus_fabric
//
module bus_fabric #(
  parameter int unsigned  AddressWidth = 32,
  parameter int unsigned  DataWidth    = 32,
  localparam int unsigned StrobeWidth  = DataWidth / 8,
  parameter int unsigned  NumTargets   = 2
)( 
  input logic clk_i,
  input logic rst_i,
  bus_if.fabric_to_initiator core_if,
  bus_if.fabric_to_target    target_ifs [NumTargets]
);
// Write buffer
  logic skid_full;
  logic skid_ready;
  logic [DataWidth-1:0]   skid_data;
  logic [StrobeWidth-1:0] skid_strb;
  //logic                   use_w_buf;  // TODO: FSM States?
  //logic                   drain_w_buf;
  //logic                   buff_full;
  //logic [DataWidth-1:0]   buff_w_data;
  //logic [StrobeWidth-1:0] buff_w_strb;

// Internal Signals
  // Status flags
  logic aw_hs_seen, w_hs_seen; 
  logic wr_inflight, rd_inflight;

  // Handshake flags
  logic aw_handshake, b_handshake, ar_handshake, r_handshake;
  logic w_direct_hs, w_buf_fill_hs, w_buf_drain_hs;

  // One-hot select lines
  logic [NumTargets-1:0] wr_sel_onehot_d;
  logic [NumTargets-1:0] wr_sel_onehot_q;
  logic [NumTargets-1:0] wr_sel_onehot;
  logic [NumTargets-1:0] rd_sel_onehot_d;
  logic [NumTargets-1:0] rd_sel_onehot_q;
  logic [NumTargets-1:0] rd_sel_onehot;

// Handshake flags
  // Write address (AW)
  assign aw_handshake = core_if.aw_valid && core_if.aw_ready;
  
  // Write data (W) fill buffer
  assign w_buf_fill_hs = core_if.w_ready && core_if.w_valid && use_w_buf;

  // Write response (B)
  assign b_handshake = core_if.b_ready && core_if.b_valid;
  
  // Read address (AR)
  assign ar_handshake = core_if.ar_valid && core_if.ar_ready;
  
  // Read data (R)
  assign r_handshake = core_if.r_ready && core_if.r_valid;

// In-flight flag
  assign wr_inflight = aw_hs_seen && w_hs_seen;

// Write Data (W) buffer flags
  assign use_w_buf = core_if.w_valid && !aw_hs_seen && !w_hs_seen && !buff_full && !core_if.aw_valid; // Schronous AW/W support
  assign drain_w_buf = buff_full && aw_hs_seen;

// Latched selection while transaction is in-flight                     // Redundant?
  assign wr_sel_onehot = aw_hs_seen ? wr_sel_onehot_q : wr_sel_onehot_d;
  assign rd_sel_onehot = rd_inflight ? rd_sel_onehot_q : rd_sel_onehot_d;

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

      skid_target <= 0;
    end else begin
      if (aw_handshake && !aw_hs_seen) begin
        aw_hs_seen <= 1'b1; 
                
        wr_sel_onehot_q <= wr_sel_onehot_d;
      end


      if (core_if.w_valid && !target_ifs_w_ready && !skid_full) begin
        skid_data  <= core_if.w_data;
        skid_strb  <= core_if.w_strb;
        skid_full  <= 1'b1;
      end

    // Target accepted buffered write data 
      if (w_buf_drain_hs) begin
        w_hs_seen   <= 1'b1;
        buff_w_data <= '0;
        buff_w_strb <= '0;
        buff_full   <= 1'b0;
      end

    // Target accepted write data from Initator 
      if (w_direct_hs) begin
        w_hs_seen <= 1'b1;
      end

      
      if (b_handshake && wr_inflight) begin
        aw_hs_seen <= 1'b0;
        w_hs_seen  <= 1'b0;
        wr_sel_onehot_q <= '0;

      end

      if (ar_handshake && !rd_inflight) begin
        rd_inflight  <= 1'b1;

        rd_sel_onehot_q <= rd_sel_onehot_d;
      end
      
      if (r_handshake && rd_inflight) begin
        rd_inflight     <= 1'b0;
        rd_sel_onehot_q <= '0;
      end
    end
  end
  

// Bus generate block 
  genvar g;
  generate
    for (g = 0; g < NumTargets; g++) begin
  // Forward routing
      always_comb begin : target_demux
    // Defaults
      //Write handshakes
        w_direct_hs    = 0'b0;
        w_buf_drain_hs = 0'b0;

      // Write channels
          // AW
        target_ifs[g].aw_valid = 1'b0;
        target_ifs[g].aw_addr  = '0;
        // W
        target_ifs[g].w_valid = 1'b0;
        target_ifs[g].w_data  = '0;
        target_ifs[g].w_strb  = '0;
        // B
        target_ifs[g].b_ready = 1'b0;

      // Read channels
        // AR
        target_ifs[g].ar_valid = 1'b0;
        target_ifs[g].ar_addr  = '0;
        // R
        target_ifs[g].r_ready = 1'b0;

    // Routing
      // Write channels
        if (wr_sel_onehot[g]) begin
        // AW
            target_ifs[g].aw_valid = core_if.aw_valid;
            target_ifs[g].aw_addr  = core_if.aw_addr;

        // W
          if (skid_full) begin 
            target_ifs[g].w_valid = 1'b1; 
            target_ifs[g].w_data  = skid_data;  
            target_ifs[g].w_strb  = skid_strb;  
          end else begin
            target_ifs[g].w_valid = core_if.w_valid;
            target_ifs[g].w_data  = core_if.w_data; 
            target_ifs[g].w_strb  = core_if.w_strb; 
          end
        
        // B
          if (wr_inflight) begin                              // inflight needed?
            target_ifs[g].b_ready = core_if.b_ready;
          end
        end
        

      // Read channels
        if (rd_sel_onehot[g]) begin
        // AR
          if (!rd_inflight) begin 
            target_ifs[g].ar_valid = core_if.ar_valid;
            target_ifs[g].ar_addr  = core_if.ar_addr;
          end

        // R
          target_ifs[g].r_ready = core_if.r_ready;
        end
      end // end of target_demux
  
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

      // Write channels

        // W      
        core_if.w_ready = wr_sel_onehot[g] ? target_ifs[g].w_ready : !skid_full;   // && !w_hs_seen?
        target_ifs_w_ready = wr_sel_onehot[g] ? target_ifs[g].w_ready : 1'b0;
        if (wr_sel_onehot[g]) begin
        // AW
          core_if.aw_ready = aw_hs_seen ? 1'b0 : target_ifs[g].aw_ready; // Redundant aw_hs_seen?
        // B
          core_if.b_valid  = target_ifs[g].b_valid;
          core_if.b_resp   = target_ifs[g].b_resp;
        end 

      // Read channels
        if (rd_sel_onehot[g]) begin
        // AR
          core_if.ar_ready = rd_inflight ? 1'b0 : target_ifs[g].ar_ready;
        // R
          core_if.r_valid = target_ifs[g].r_valid;
          core_if.r_data = target_ifs[g].r_data;
          core_if.r_resp = target_ifs[g].r_resp;
        end
      end // initiator_mux
    end
  endgenerate

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
