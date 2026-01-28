//  Module: bus_fabric
//
module bus_fabric #(
  parameter int unsigned AddressWidth = 32,
  parameter int unsigned DataWidth    = 32,
  parameter int unsigned NumTargets   = 2
)( 
  bus_if.initiator core_if,
  bus_if.target    target_ifs [NumTargets]
);

// Internal Signals

  logic [NumTargets-1:0] sel_onehot;
  

// Fowards initiators request to exactly one target
  always_comb begin : target_mux // Request-side mux TODO
    unique case (sel_onehot)
      :
      :
      default:
    endcase
  end

// Forwards target's response to initiator
  always_comb begin : initiator_mux // Response-side mux TODO
    unique case (sel_onehot)
      :
      :
      default:
    endcase
  end

  bus_addr_decode #(
    .AddressWidth(AddressWidth),
    .NumTargets(NumTargets)
  )(
    .valid_i(core_valid_i),
    .addr_i(core_addr_i),
    sel_onehot_o(sel_onehot)
  );
  
endmodule
