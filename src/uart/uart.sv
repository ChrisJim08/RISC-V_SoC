module uart_ctrl #(
  parameter int unsigned DataWidth      = 8,
  parameter int unsigned FifoDepth      = 16,
  parameter int unsigned ClockFrequency = 50_000_000,
  parameter int unsigned OverSampleRate = 16
) (
  input  logic        clk_i,
  input  logic        rst_i,

  input  logic        wr_en_i,
  input  logic [1:0]  addr_i,
  input  logic [15:0] data_i,
  input  logic        rxd_i,
  output logic        txd_o
);

  logic tick_s;
  
  logic rx_busy_s, tx_busy_s;

  baud_gen #(
    .ClockFrequency(ClockFrequency),
    .OverSampleRate(OverSampleRate)
  ) baud_generator (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .rx_busy_i(rx_busy_s),
    .tx_busy_i(tx_busy_s),
    .baud_sel_i(),
    .baud_tick_o(tick_s)
  );

  uart_rx #(
    .DataWidth(DataWidth)
  ) uart_reciever (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .tick_i(tick_s),
    .rxd_i(rxd_i),
    .dv_o(),
    .data_o()
  );

  fifo #(
    .DataWidth(DataWidth),
    .Depth(FifoDepth)
  ) recieve_fifo (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .wr_en_i(),
    .rd_en_i(),
    .wr_data_i(),
    .full_o(),
    .empty_o(),
    .rd_data_o()
  );

  uart_tx #(
    .DataWidth(DataWidth)
  ) uart_transmitter (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .tick_i(tick_s),
    .dv_i(),
    .data_i(),
    .txd_o(txd_o), 
    .busy_o(tx_busy_s)
  );

  fifo #(
    .DataWidth(DataWidth),
    .Depth(FifoDepth)
  ) transmit_fifo (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .wr_en_i(),
    .rd_en_i(),
    .wr_data_i(),
    .full_o(),
    .empty_o(),
    .rd_data_o()
  );


endmodule