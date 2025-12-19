module uart_ctrl #(
  parameter int unsigned DataWidth = 8
) (
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        wr_en_i,
  input  logic [1:0]  addr_i,
  input  logic [15:0] data_i,
  input  logic        rx_data_i,
  output logic [7:0]  tx_data_o
);


  uart_rx uart_reciever (

  );

  uart_tx uart_transmitter (

  );

  baud_gen #(
    .DataWidth(DataWidth)
  ) baud_generator (
    .clk_i(),
    .rst_i(),
    .tick_i(),
    .rx_data_i(),
    .rx_dv_o(),
    .data_o()
);

endmodule