//  Module: bus_addr_decode
//
module bus_addr_decode
  #(
    parameter int unsigned DataWidth = 32
  )(
    input  logic                 valid_i,
    input  logic [DataWidth-1:0] addr_i,
    output logic [10:0]          sel_onehot_o
  );

  always_comb begin
    casez (addr_i)
      : 
      default: 
    endcase
    
  end

  
endmodule
