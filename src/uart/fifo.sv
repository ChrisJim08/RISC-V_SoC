module fifo #(
  parameter  int unsigned DataWidth    = 32,
  parameter  int unsigned Depth        = 16,
  localparam int unsigned PointerWidth = $clog2(Depth)
) (
  input logic                  clk_i,
  input logic                  rst_i,
  input logic                  wr_en_i,
  input logic                  rd_en_i,
  input logic [DataWidth-1:0]  wr_data_i,
  output logic                 full_o,
  output logic                 empty_o,
  output logic [DataWidth-1:0] rd_data_o
);

  // Pointers
  logic [PointerWidth-1:0] rd_pointer;
  logic [PointerWidth-1:0] wr_pointer;

  // FIFO
  logic [DataWidth-1:0] fifo [Depth-1:0];

  // Variable
  integer i;
  logic [PointerWidth-1:0] count;

  assign empty_o = (count == '0);
  assign full_o  = (count == Depth);

  always_ff @(posedge clk_i) begin
    if(rst_i) begin
      rd_pointer = '0;
      wr_pointer = '0;
      for (i = 0; i < Depth ; i++) begin
        fifo[i] = '0;
      end
    end else if (rd_en_i && !wr_en_i && !empty_s) begin
      rd_data_o = fifo[rd_pointer];
      rd_pointer++;
      count--;
    end else if (wr_en_i && !rd_en_i && !full_s) begin
      fifo[wr_pointer] = wr_data_i;
      wr_pointer++;
      count++;
    end else if (wr_en_i && rd_en_i) begin
      if (!full_s && !empty_s) begin
        rd_data_o = fifo[rd_pointer];
        fifo[wr_pointer] = data_i;
      end
    end else 
    ...
  end

endmodule