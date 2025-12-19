`include "baud_gen.svh"
module baudx16_gen #(
  parameter int unsigned ClockFrequency = 50_000_000
) (
  input  logic       clk_i,
  input  logic       rst_i,
  input  logic [1:0] baud_sel_i,
  output logic       baudx16_tick_o
);

  int unsigned baud; // Make width of Clockfreq?
  int unsigned divsor; 
  //logic [$clog2(ClockFrequency)-1:0)] cur_count
  int unsigned cur_count; //make width of $clog(divsor)
  //int unsigned next_count;

always_comb begin
  unique case (baud_sel_i)
    2'b00: baud = BAUD_1900_RATE;
    2'b01: baud = BAUD_19200_RATE;
    2'b10: baud = BAUD_57600_RATE;
    2'b11: baud = BAUD_115200_RATE;
  endcase
  divsor = ClockFrequency / baud;
end


always_ff @(posedge clk_i) begin
  if (rst_i ||  (cur_count == (divsor-1))) begin
    cur_count <= '0;
  end else begin
    cur_count <= cur_count + 1;
  end
end

assign baudx16_tick_o = (cur_count == divsor);


endmodule 
