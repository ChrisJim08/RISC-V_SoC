//  Module: bus_fabric
//
module bus_fabric #(
  parameter int unsigned AddressWidth    = 32,
  parameter int unsigned DataWidth       = 32
)( 
  input  logic                     core_valid_i,
  input  logic [AddressWidth-1:0 ] core_addr_i,
  input  logic [DataWidth-1:0]     core_data_i,
  output logic [DataWidth-1:0]     core_data_o 
);

// Localparameters

  localparam int unsigned NumSubordinates = 2;  // will probably not use, just hardcode it in

// Internal Signals

  logic [NumSubordinates-1:0] sel_onehot;
  


  // Fowards managers request to exactly one subordinate
  always_comb begin : subordinate_mux // Request-side mux
    unique case (sel_onehot)
      :
      :
      default:
    endcase
  end

  // Forwards subordinate's response to manager
  always_comb begin : manager_mux // Response-side mux
    unique case (sel_onehot)
      :
      :
      default:
    endcase
  end

  bus_addr_decode #(
    .AddressWidth(AddressWidth),
    .DataWidth(DataWidth),
    .NumSubordinates(NumSubordinates)
  )(
    .valid_i(core_valid_i),
    .addr_i(core_addr_i),
    sel_onehot_o(sel_onehot)
  );

  
endmodule
