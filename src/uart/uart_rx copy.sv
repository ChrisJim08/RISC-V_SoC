module uart_rx #(
  parameter  int unsigned DataWidth  = 8,
  localparam int unsigned CountWidth = $clog2(DataWidth)
  ) (
  input  logic                 clk_i,
  input  logic                 rst_i,
  input  logic                 tick_i,
  input  logic                 rx_data_i,
  output logic                 rx_dv_o,
  output logic [DataWidth-1:0] data_o
);

  // rx data lines
  logic rx_data_r;
  logic rxd;

  // Double register to reduce metastability
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      rx_data_r <= 1;
      rxd       <= 1;
    end else begin
      rx_data_r <= rx_data_i;
      rxd       <= rx_data_r;
    end
  end

  // States
  typedef enum { 
    Idle, StartBit, DataBits, StopBit 
  } uart_state_e;

  // State Registers
  uart_state_e cur_state;
  uart_state_e next_state;

  // Count register
  logic [CountWidth:0] count;

  // Indicates 
  logic sbuff_full;

  // Shift buffer regisers
  logic [DataWidth-1:0] sbuff_reg;

  always_ff @(posedge clk_i or posedge rst_i) begin : memory_block
    if (rst_i) begin
      cur_state <= Idle;
      sbuff_reg <= '0;
      count     <= '0;
    end else begin
      cur_state    <= next_state;

      if (cur_state == StartBit) begin
        count <= '0;
      end else if (cur_state == DataBits) begin
        sbuff_reg <= {rxd, sbuff_reg[DataWidth-1:1]};
        count <= count + 1;
      end

      //rx_dv_o <= (cur_state == StopBit) ? 1'b1 : 1'b0;

    end
  end
  
  assign sbuff_full = count[CountWidth];
  assign data_o  = sbuff_reg;

  always_comb begin : next_state_logic
    next_state = cur_state;
    rx_dv_o    = 1'b0;
    if (tick_i) begin
      unique case (cur_state)    
        Idle: if (!rxd) next_state = StartBit;
        StartBit: next_state = DataBits;
        DataBits: if (sbuff_full) next_state = StopBit;
        StopBit: begin 
          next_state = Idle;
          rx_dv_o    = 1'b1;
        end
        default: ;
      endcase
    end 
  end
endmodule
