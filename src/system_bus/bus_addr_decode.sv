//  Module: bus_addr_decode
//

import memmap_pkg::*;

module bus_addr_decode #(
  parameter int unsigned AddressWidth = 32,
  parameter int unsigned NumTargets   = 2
)(
  input  logic                    valid_i,
  input  logic [AddressWidth-1:0] addr_i,
  output logic                    addr_hit_o,
  output logic [NumTargets-1:0]   sel_onehot_o
);

  always_comb begin
    sel_onehot_o = '0;
    addr_hit_o   = 1'b0;

    if (valid_i) begin
      if (addr_i < RamLimit) begin // RAM
        addr_hit_o           = 1'b1;
        sel_onehot_o[RamIdx] = 1'b1;
       end
      else begin
        unique0 case (addr_i[AddressWidth-1:12])
          UartKey: begin // UART
            addr_hit_o            = 1'b1;
            sel_onehot_o[UartIdx] = 1'b1;
          end
          default: begin
            // TODO Unmapped
          end
        endcase
      end
    end
  end
  
endmodule
