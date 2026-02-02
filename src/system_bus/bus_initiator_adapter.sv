//  Module: bus_initiator_adapter
//
module bus_initiator_adapter #(
  parameter int unsigned AddressWidth = 32,
  parameter int unsigned DataWidth    = 32
)(
  input  logic                     valid_i,
  input  logic [AddressWidth-1:0 ] addr_i,
  input  logic [DataWidth-1:0]     data_i,
  output logic [DataWidth-1:0]     data_o,
  bus_if.initiator                 bus
);

  always_ff @(posedge clock ) begin
    
  end
  if (valid_i) begin
    
  end
  
endmodule
