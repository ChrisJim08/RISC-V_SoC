//  Module: bus_addr_decode
//
module bus_addr_decode #(
  parameter int unsigned AddressWidth = 32,
  parameter int unsigned DataWidth    = 32,
  parameter int unsigned NumTargets   = 2
)(
  input  logic                  valid_i,
  input  logic [DataWidth-1:0]  addr_i,
  output logic                  addr_hit, // Is this needed?
  output logic [NumTargets-1:0] sel_onehot_o
);

  always_comb begin
    unique case (addr_i)
      : 
      :
      default:
    endcase
    // How will I implement out of range addresses?
      // If dummy target, use unique0

    // Will possibly implement addr_offset for local addresses within target regs
    
  end

  
endmodule
