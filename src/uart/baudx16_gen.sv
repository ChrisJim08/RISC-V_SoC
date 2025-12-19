module baudx16_gen #(
  parameter  int unsigned ClockFrequency   = 50_000_000,
  localparam int unsigned Baud1900Divsor   = ClockFrequency / 1900,
  localparam int unsigned Baud19200Divsor  = ClockFrequency / 19200,
  localparam int unsigned Baud57600Divsor  = ClockFrequency / 57600,
  localparam int unsigned Baud115200Divsor = ClockFrequency / 115200,
  localparam int unsigned MinDivsorWidth   = $clog2(Baud1900Divsor)
) (
  input  logic       clk_i,
  input  logic       rst_i,
  input  logic [1:0] baud_sel_i,
  output logic       baudx16_tick_o
);

  logic [MinDivsorWidth-1:0] divsor;
  logic [MinDivsorWidth-1:0] count_reg;
  logic [MinDivsorWidth-1:0] next_count;

  always_comb begin
    // TODO if (!tx_busy || !rx_busy)
    // make divsor_reg and divsor_next which makes it possible to change after byte
    unique case (baud_sel_i)
      2'b00: divsor = MinDivsorWidth'(Baud1900Divsor);
      2'b01: divsor = MinDivsorWidth'(Baud19200Divsor);
      2'b10: divsor = MinDivsorWidth'(Baud57600Divsor);
      2'b11: divsor = MinDivsorWidth'(Baud115200Divsor);
    endcase

    baudx16_tick_o = 1'b0;

    if (count_reg == (divsor-1)) begin
      baudx16_tick_o = 1'b1;
      next_count     = '0;
    end else next_count = count_reg + 1;
  end

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      count_reg <= '0;
    end else begin
      count_reg <= next_count;
    end
  end
endmodule 
