//  Module: bus_initiator_adapter
//
module bus_initiator_adapter #(
  parameter int unsigned AddressWidth = 32,
  parameter int unsigned DataWidth    = 32
)(
  bus_if.initiator                 bus,
  input  logic                     valid_i,
  input  logic [AddressWidth-1:0 ] addr_i,
  input  logic [DataWidth-1:0]     data_i,
  output logic [DataWidth-1:0]     data_o 
);

  /*
  Standardizes how initiators talk to the bus
    are the signals using the ports needed or will the core use the signals within the bus_if?

  */
  
endmodule
