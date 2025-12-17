module uart_rx #(
  parameter   DataWidth  = 8,
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
  uart_state_e state_q;
  uart_state_e state_d;

  // Count register
  logic [CountWidth:0] count;

  // Shift buffer regisers
  logic [DataWidth-1:0] sbuff_reg;

  always_ff @(posedge clk_i or posedge rst_i) begin : memory_block
    if (rst_i) begin
      state_q   <= Idle;
      sbuff_reg <= '0;
      count     <=  0;
    end else begin
      state_q    <= state_d;
      if (state_q == StartBit) begin
        count <= 0;
      end

      if (tick_i && (state_q == DataBits)) begin
        sbuff_reg <= {rxd, sbuff_reg[DataWidth-1:1]};
        count <= count + 1;
      end
      if (state_q == StopBit) begin
        data_o <= sbuff_reg;
      end

    end
  end
  
  assign rx_dv_o = (state_q == StopBit);

  always_comb begin 
    state_d = state_q;
    unique case (state_q)    
      Idle: begin
        if (!rxd) begin
          state_d = StartBit;
        end 
      end
      StartBit: begin
        if (tick_i) begin
          state_d = DataBits;
        end
      end
      DataBits: begin
        if (count == DataWidth) begin
          state_d = StopBit;
        end
      end
      StopBit: begin
        state_d = Idle;
      end
      default: begin
      end
    endcase
  end

endmodule
