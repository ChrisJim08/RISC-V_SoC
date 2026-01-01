module uart_ctrl #(
  parameter int unsigned UartDataWidth  = 8,
  parameter int unsigned BusDataWidth  = 32,
  parameter int unsigned FifoDepth      = 16,
  parameter int unsigned ClockFrequency = 50_000_000,
  parameter int unsigned OverSampleRate = 16
) (
  input  logic                    clk_i,
  input  logic                    rst_i,
  input  logic                    rxd_i,
  input  logic                    bus_wr_en_i,
  input  logic [BusDataWidth-1:0] bus_addr_i,
  input  logic [BusDataWidth-1:0] bus_wdata_i,
  output logic                    txd_o,
  output logic [BusDataWidth-1:0] bus_rdata_o
);
  
  //TODO EXPLAIN THIS
  logic rx_busy_s, rx_busy_r, tx_busy_s;
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i)
      rx_busy_s <= 1'b0;
    else
      rx_busy_s <= rx_busy_r;
  end

  //Configurable (R/W) Baud Rate Register
  logic [BusDataWidth-1:0] baud_rate_reg;

  //Read-only Line Status Register
  logic [BusDataWidth-1:0] status_reg;
  assign status_reg = BusDataWidth'({tx_busy_s,rx_busy_s,rx_valid});

  //Read-only Reciever data Register
  logic [BusDataWidth-1:0] rx_data_reg;

  //Write-only Transmitter data Register
  logic [BusDataWidth-1:0] tx_data_reg;

  always_comb begin //TODO: Correctly implement register logic, using q and d signals
    bus_rdata_o = '0;
    unique case (bus_addr_i[1:0])
      2'b00: begin : baud_rate_register
        if (bus_wr_en_i) begin
          baud_rate_reg = bus_wdata_i; 
        end else begin
          bus_rdata_o = baud_rate_reg;
        end
      end
      2'b01: begin : line_status_register
        bus_rdata_o = status_reg;
      end
      2'b10: begin : reciever_data_register
        bus_rdata_o = rx_data_reg;
      end
      2'b11: begin : transmitter_data_register
        if (bus_wr_en_i) tx_data_reg = bus_wdata_i; 
      end
      default: ;
    endcase
  end

  logic baud_clk_s; //TODO: Correct circular combinational logic (after TOD0 above)

  baud_gen #(
    .ClockFrequency(ClockFrequency),
    .OverSampleRate(OverSampleRate)
  ) baud_generator (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .rx_busy_i(rx_busy_s),
    .tx_busy_i(tx_busy_s),
    .baud_sel_i(baud_rate_reg[1:0]),
    .baud_clk_o(baud_clk_s)
  );

  logic rx_valid;
  logic [UartDataWidth-1:0] rx_data_s;

  uart_rx #(
    .DataWidth(UartDataWidth)
  ) uart_reciever (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .baud_clk_i(baud_clk_s),
    .rxd_i(rxd_i),
    .dv_o(rx_valid),
    .busy_o(rx_busy_r),
    .data_o(rx_data_s)
  );

  fifo #(
    .DataWidth(UartDataWidth),
    .Depth(FifoDepth)
  ) recieve_fifo (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .rd_en_i(),
    .wr_en_i(rx_valid),
    .wr_data_i(rx_data_s),
    .full_o(),
    .empty_o(),
    .rd_data_o(rx_data_reg[7:0]) // Need to clock register?
  );

  logic tx_fifo_empty;
  logic [UartDataWidth-1:0] tx_data;

  fifo #(
    .DataWidth(UartDataWidth),
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
    .DataWidth(UartDataWidth)
  ) uart_transmitter (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .baud_clk_i(baud_clk_s),
    .dv_i(tx_fifo_empty),
    .data_i(tx_data),
    .txd_o(txd_o), 
    .busy_o(tx_busy_s)
  );


endmodule
