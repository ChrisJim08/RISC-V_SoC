module uart_tx #(
  parameter  int unsigned DataWidth  = 8,
  localparam int unsigned CountWidth = $clog2(DataWidth)
  ) (
  input  logic                 clk_i,
  input  logic                 rst_i,
  input  logic                 baud_clk_i,
  input  logic                 dv_i,
  input  logic [DataWidth-1:0] data_i,
  output logic                 txd_o,
  output logic                 busy_o
);

  // States
  typedef enum { 
    Idle, StartBit, DataBits, StopBit 
  } uart_state_e;

  // State Registers
  uart_state_e state_reg;
  uart_state_e next_state;

  // Shift buffer registers
  logic [DataWidth-1:0] sbuff_reg;
  logic [DataWidth-1:0] next_sbuff;

  // Count registers
  logic [CountWidth-1:0] count_reg;
  logic [CountWidth-1:0] next_count;


  always_ff @(posedge clk_i or posedge rst_i) begin : memory_block
    if (rst_i) begin
      state_reg <= Idle;
      sbuff_reg <= '0;
      count_reg <= '0;
    end else begin
      state_reg <= next_state;
      count_reg <= next_count;
      sbuff_reg <= next_sbuff;
    end
  end

  // Indicates when shift buffer is full
  logic  sbuff_empty;
  assign sbuff_empty = (count_reg == CountWidth'(DataWidth-1));

  always_comb begin : next_state_logic
    next_state = state_reg;
    next_count = count_reg;
    next_sbuff = sbuff_reg;
    
    txd_o     = 1'b1;
    busy_o    = 1'b1;

    unique case (state_reg)    
      Idle: begin
        if (dv_i) begin
          next_sbuff = data_i;
          next_state = StartBit;
        end else busy_o = 1'b0;
      end
      StartBit: begin
        if (baud_clk_i) begin
          txd_o      = 1'b1;
          next_state = DataBits;
        end
      end
      DataBits: begin
        if (baud_clk_i) begin
          txd_o      = sbuff_reg[0];
          next_sbuff = sbuff_reg >> 1;
          next_count = count_reg + 1;
          if (sbuff_empty) next_state = StopBit;
        end
      end
      StopBit: begin 
        if (baud_clk_i) begin
          txd_o    = 1'b0;
          next_state = Idle;
        end
      end
      default: ;
    endcase
  end
endmodule
