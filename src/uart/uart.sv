module uart_ctrl #(
  parameter int unsigned UartDataWidth  = 8,
  parameter int unsigned MmioDataWidth  = 32,
  parameter int unsigned FifoDepth      = 16,
  parameter int unsigned ClockFrequency = 50_000_000,
  parameter int unsigned OverSampleRate = 16
) (
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        rxd_i,
  input  logic                     mmio_wr_en_i,
  input  logic [MmioDataWidth-1:0] mmio_addr_i,
  input  logic [MmioDataWidth-1:0] mmio_wdata_i,
  output logic                     txd_o,
  output logic [MmioDataWidth-1:0] mmio_rdata_o
);
  
  logic rx_busy_s, rx_busy_r, tx_busy_s;

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i)
      rx_busy_s <= 1'b0;
    else
      rx_busy_s <= rx_busy_r;
  end

  logic [BusDataWidth-1:0] status_reg;
  logic [DataWidth-1:0] baud_reg;

  always_comb begin
    data_o = '0;
    unique case (addr_i)
      2'b00: begin : line_status_register
        mmio_rdata_o = status_reg;
      end
      2'b01: begin : baud_rate_register
        if (dv_i) begin
          baud_reg = 
        end else begin
          
        end
      end
      2'b10: begin
        data_o = '0;
      end
      2'b11: begin
        data_o = '0;
      end
      default: ;
    endcase
  end

  logic tick_s;

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

  logic rx_fifo_wr_en;
  logic [DataWidth-1:0] rx_data;

  uart_rx #(
    .DataWidth(DataWidth)
  ) uart_reciever (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .tick_i(tick_s),
    .rxd_i(rxd_i),
    .dv_o(rx_fifo_wr_en),
    .busy_o(rx_busy_r),
    .data_o(rx_data)
  );

  fifo #(
    .DataWidth(DataWidth),
    .Depth(FifoDepth)
  ) recieve_fifo (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .rd_en_i(),
    .wr_en_i(rx_fifo_wr_en),
    .wr_data_i(rx_data),
    .full_o(),
    .empty_o(),
    .rd_data_o()
  );

  logic tx_fifo_empty;
  logic [DataWidth-1:0] tx_data;

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
    .empty_o(tx_fifo_empty),
    .rd_data_o(tx_data)
  );

  logic tx_dv;
  assign tx_dv = ~tx_fifo_empty;
  uart_tx #(
    .DataWidth(DataWidth)
  ) uart_transmitter (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .tick_i(tick_s),
    .dv_i(tx_fifo_empty),
    .data_i(tx_data),
    .txd_o(txd_o), 
    .busy_o(tx_busy_s)
  );


endmodule
