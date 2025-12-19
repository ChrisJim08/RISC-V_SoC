`include "baud_gen.svh"
module baud_gen #(
  parameter  int unsigned ClockFrequency   = 50_000_000,
  parameter  int unsigned OverSampleRate   = 16,
  localparam int unsigned Baud1900Divsor   = ClockFrequency / (BAUD_1900_RATE   * OverSampleRate),
  localparam int unsigned Baud19200Divsor  = ClockFrequency / (BAUD_19200_RATE  * OverSampleRate),
  localparam int unsigned Baud57600Divsor  = ClockFrequency / (BAUD_57600_RATE  * OverSampleRate),
  localparam int unsigned Baud115200Divsor = ClockFrequency / (BAUD_115200_RATE * OverSampleRate),
  localparam int unsigned MinDivsorWidth   = $clog2(Baud1900Divsor)
) (
  input  logic       clk_i,
  input  logic       rst_i,
  input  logic       rx_busy_i,
  input  logic       tx_busy_i,
  input  logic [1:0] baud_sel_i,
  output logic       baudx16_tick_o
);

  logic  busy;
  assign busy = (tx_busy_i || rx_busy_i);

  logic [MinDivsorWidth-1:0] divsor_reg;
  logic [MinDivsorWidth-1:0] next_divsor;

  logic [MinDivsorWidth-1:0] count_reg;
  logic [MinDivsorWidth-1:0] next_count;

  always_comb begin
    unique case (baud_sel_i)
        2'b00: next_divsor = MinDivsorWidth'(Baud1900Divsor);
        2'b01: next_divsor = MinDivsorWidth'(Baud19200Divsor);
        2'b10: next_divsor = MinDivsorWidth'(Baud57600Divsor);
        2'b11: next_divsor = MinDivsorWidth'(Baud115200Divsor);
    endcase

    baudx16_tick_o = 1'b0;

    if ((next_divsor != divsor_reg) && !busy) begin
      next_count     = '0;
    end else if (count_reg == (divsor_reg-1)) begin
      next_count     = '0;
      baudx16_tick_o = 1'b1;
    end else next_count = count_reg + 1;
  end

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      count_reg   <= '0;
      divsor_reg      <= MinDivsorWidth'(Baud1900Divsor);
    end else begin
      count_reg   <= next_count;

      if (!busy) divsor_reg <= next_divsor;
    end
  end
endmodule 
