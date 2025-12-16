module uart_ctrl (
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        wr_en_i,
  input  logic [1:0]  addr_i,
  input  logic [15:0] data_i,
  input  logic        rx_data_i,
  output logic [7:0]  tx_data_o
);

  // 
  // Registers
  logic [15:0] baud_rate_reg;


  uart_rx uart_reciever (

  );

  uart_tx uart_transmitter (

  );

  baud_gen baud_generator (
    
  );

endmodule