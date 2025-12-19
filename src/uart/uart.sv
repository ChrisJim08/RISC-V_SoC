module uart_ctrl #(
  parameter int unsigned DataWidth = 8,
  parameter int unsigned ClockFrequency = 50_000_000,
  parameter int unsigned OverSampleRate = 16
) (
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        wr_en_i,
  input  logic [1:0]  addr_i,
  input  logic [15:0] data_i,
  input  logic        rx_data_i,
  output logic [7:0]  tx_data_o
);


  uart_rx #(
    .DataWidth(DataWidth)
  ) uart_reciever (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .tick_i(),
    .rx_data_i(),
    .rx_dv_o(),
    .data_o()
);

  uart_tx uart_transmitter (

  );

  baud_gen #(
    .ClockFrequency(ClockFrequency),
    .OverSampleRate(OverSampleRate)
  ) baud_generator (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .rx_busy_i(),
    .tx_busy_i(),
    .baud_sel_i(),
    .baudx16_tick_o()
);

endmodule