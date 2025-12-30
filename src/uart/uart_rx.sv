module uart_rx #(
  parameter  int unsigned DataWidth  = 8,
  localparam int unsigned CountWidth = $clog2(DataWidth)
  ) (
  input  logic                 clk_i,
  input  logic                 rst_i,
  input  logic                 tick_i,
  input  logic                 rxd_i,
  output logic                 dv_o,
  output logic                 busy_o,
  output logic [DataWidth-1:0] data_o
);

  // rx data lines
  logic rxd_r;
  logic rxd;

  // Double register to reduce metastability
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      rxd_r <= 1;
      rxd   <= 1;
    end else begin
      rxd_r <= rxd_i;
      rxd   <= rxd_r;
    end
  end

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

  // Indicates when shift buffer is full
  logic  sbuff_full;
  assign sbuff_full = (count_reg == CountWidth'(DataWidth-1));

  assign data_o  = sbuff_reg;

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

  always_comb begin : next_state_logic
    next_state = state_reg;
    next_count = count_reg;
    next_sbuff = sbuff_reg;
    
    dv_o    = 1'b0;
    busy_o  = 1'b1;

    if (tick_i) begin
      unique case (state_reg)    
        Idle: begin
          if (!rxd) begin
            next_state = StartBit;
          end else busy_o = 1'b0;
        end
        StartBit: begin
          next_sbuff = {rxd, sbuff_reg[DataWidth-1:1]};
          next_count = count_reg + 1;
          next_state = DataBits;
        end
        DataBits: begin
          next_sbuff = {rxd, sbuff_reg[DataWidth-1:1]};
          next_count = count_reg + 1;
          if (sbuff_full) next_state = StopBit;
        end
        StopBit: begin 
          next_state = Idle;
          dv_o    = 1'b1;
        end
        default: ;
      endcase
    end 
  end
endmodule
