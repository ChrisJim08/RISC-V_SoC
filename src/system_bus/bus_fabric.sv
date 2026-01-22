//  Module: bus_fabric
//
module bus_fabric #(
  parameter int unsigned AddressWidth    = 32,
  parameter int unsigned DataWidth       = 32
)( 
  input  logic [AddressWidth-1:0 ] addr_i,
  input  logic [DataWidth-1:0]     data_i,
  output logic [DataWidth-1:0]     data_o 
);

// Localparameters

  localparam int unsigned NumSubordinates = 2;  // will probably not use, just hardcode it in

// Internal Signals

  logic [NumSubordinates-1:0] sel_onehot;

  always_comb begin : subordinate_mux
    unique case (sel_onehot)
      :
      :
      default:
    endcase
  end

  always_comb begin : response_mux
    unique case ()
      :
      :
      default:
    endcase
  end

  
endmodule
