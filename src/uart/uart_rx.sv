module uart_rx #(
  parameter int CLKS_PER_BIT = 87 //CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART (baud rate))
) (
  input  logic       clk_i,7
  input  logic       rst_ni,
  input  logic       rx_i,
  output logic       rx_dv_o,
  output logic [7:0] data_o
);

  localparam integer CLOCK_COUNT_WIDTH = $clog2(CLKS_PER_BIT); //int or integer??????????????????????//
  
  typedef enum { 
    Idle, StartBit, DataBits, StopBit //Reset/Cleanup state???????????????????
  } uart_state_e;

  // State Registers
  uart_state_e cur_state_d;
  uart_state_e nxt_state_q;

  // FSM logic 
  logic [2:0]                   bit_index;
  logic [CLOCK_COUNT_WIDTH-1:0] clock_count;

  // rx data lines
  logic rx_data_r;
  logic rx_data;

  // Double register to reduce metastability
  always_ff @(posedge clk_i) begin
    rx_data_r <= rx_i;
    rx_data   <= rx_data_r;
  end

  // Register State
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      cur_state_d <= Idle;
    end else begin
      cur_state_d <= nxt_state_q;
    end
    
  end

  // Next State Logic
  always_comb begin
    nxt_state_q = cur_state_d;
    unique case (cur_state_d)
      Idle: begin
        nxt_state_q = StartBit;
      end
      StartBit: begin
        nxt_state_q = DataBits;
      end
      DataBits: begin
        nxt_state_q = StopBit;
      end
      StopBit: begin
        nxt_state_q = Idle;
      end
      default: begin

      end
    endcase
  end

  assign data_o = ;

endmodule