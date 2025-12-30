module fifo #(
  parameter  int unsigned DataWidth    = 32,
  parameter  int unsigned Depth        = 16, // Depth must be a power of 2 due to wrap-bit validation method 
  localparam int unsigned PointerWidth = $clog2(Depth)
) (
  input logic                  clk_i,
  input logic                  rst_i,
  input logic                  rd_en_i,
  input logic                  wr_en_i,
  input logic [DataWidth-1:0]  wr_data_i,
  output logic                 full_o,
  output logic                 empty_o,
  output logic [DataWidth-1:0] rd_data_o
);

  // Pointers with wrap-around bit (MSB) for status 
  logic [PointerWidth:0] rd_ptr, wr_ptr;

  // FIFO memory block
  logic [DataWidth-1:0]  mem [Depth-1:0];
  
  // Read/Write validation
  logic  rd_valid , wr_valid;
  assign rd_valid = (rd_en_i && !empty_o);
  assign wr_valid = (wr_en_i && !full_o);

  // Status flag logic
  assign empty_o = (rd_ptr == wr_ptr);
  assign full_o  = (rd_ptr == {~wr_ptr[PointerWidth], wr_ptr[PointerWidth-1:0]});

  always_ff @(posedge clk_i) begin
    if(rst_i) begin
      rd_ptr    <= '0;
      wr_ptr    <= '0;
      rd_data_o <= '0;
    end 
    else begin
      if (rd_valid) begin
        rd_data_o <= mem[rd_ptr[PointerWidth-1:0]];
        rd_ptr    <= rd_ptr + 1;
      end
      if (wr_valid) begin
        mem[wr_ptr[PointerWidth-1:0]] <= wr_data_i;
        wr_ptr                        <= wr_ptr + 1;
      end 
    end
  end

  initial begin
    if ((Depth & (Depth-1)) != 0) $error("FIFO Depth must be power of two");
  end
endmodule
