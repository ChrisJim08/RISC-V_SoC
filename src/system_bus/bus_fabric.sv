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

  logic [NumTargets-1:0] sel_onehot_r;
  logic [NumTargets-1:0] sel_onehot;

  always_ff @(posedge clk_i) begin
    
  end


  

// Write address (AW) forward routing
  always_comb begin : aw_req_demux
    target_ifs[RamIdx].aw_valid  = 1'b0;
    target_ifs[UartIdx].aw_valid = 1'b0;
    target_ifs[RamIdx].aw_addr   = '0;
    target_ifs[UartIdx].aw_addr  = '0;

    unique case (sel_onehot)
      RamSelOneHotId: begin
          target_ifs[RamIdx].aw_valid = aw_valid;
          target_ifs[RamIdx].aw_addr = core_if.aw_addr;
      end
      UartSelOneHotId: begin
          target_ifs[UartIdx].aw_valid = aw_valid;
          target_ifs[UartIdx].aw_addr = core_if.aw_addr;
      end
      default:  ;
    endcase
    
  end

// Write data (W) forward routing
  always_comb begin : w_req_demux
      if (aw_valid && aw_ready)

      unique case (sel_onehot)
        RamSelOneHotId: begin
        end
        UartSelOneHotId: begin
        end
      endcase
  end
  
// Forwards target's response to initiator
  always_comb begin : initiator_mux // Response-side mux TODO
    core_if.aw_ready = 1'b0;

    unique case (sel_onehot)
      RamSelOneHotId: begin
        core_if.aw_ready = target_ifs[RamIdx].aw_ready;
      end
      UartSelOneHotId: begin
        core_if.aw_ready = target_ifs[UartIdx].aw_ready;
      end
      default:  ;
    endcase
  end

  bus_addr_decode #(
    .AddressWidth(AddressWidth),
    .NumTargets(NumTargets)
  ) addr_decoder (
    .valid_i(core_if.aw_valid),
    .addr_i(core_if.aw_addr),
    .sel_onehot_o(sel_onehot)
  );
  
endmodule
