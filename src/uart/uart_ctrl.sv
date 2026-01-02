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
  // TODO Fix rx.busy_o signal and finish status register
  // Make sure size'(data) does not make synthesis optimization wacky (doesn't optimize the extra bits away)
  // Does rd_data make sense (rd_data = read-data_data)????
  // Should reg sizes be UartDataWidth?
  // Should bus inputs be UartDataWidth?
  // Fix fifo rd and wr pointers to have d /q?
  // Internal signals
  logic baud_clk_s;
  logic rx_valid_s;
  logic [UartDataWidth-1:0] rx_data_s;
  logic rx_fifo_rd_en_s;
  logic rx_fifo_full_s;
  logic rx_fifo_empty_s;
  logic [UartDataWidth-1:0] rx_fifo_rd_data_s; // Better name?
  logic tx_valid_s;
  assign tx_valid_s = ~tx_fifo_empty_s;
  logic tx_fifo_wr_en_s;
  logic tx_fifo_full_s;
  logic tx_fifo_empty_s;
  logic [UartDataWidth-1:0] tx_fifo_rd_data_s;

  // Signal part-selecting
  logic [1:0] baud_sel_s;
  assign baud_sel_s = baud_rate_q[1:0];
  
  // TODO EXPLAIN THIS
  logic rx_busy_s, rx_busy_r, tx_busy_s;
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      rx_busy_s <= 1'b0;
    end else begin
      rx_busy_s <= rx_busy_r;
    end
  end

  // Configurable (R/W) Baud Rate Register
  logic [BusDataWidth-1:0] baud_rate_d;
  logic [BusDataWidth-1:0] baud_rate_q;

  // Read-only Line Status Register
  logic [BusDataWidth-1:0] status_reg;
  assign status_reg = BusDataWidth'({tx_busy_s,rx_busy_s,rx_valid_s});

  // Read-only Reciever data Register (fifo rd_o)
  //logic [BusDataWidth-1:0] rx_data_reg;             // Needed?
  //assign rx_data_reg[7:0] = rx_fifo_rd_data_s;

  // Write-only Transmitter data Register
  logic [UartDataWidth-1:0] tx_data_d;
  logic [UartDataWidth-1:0] tx_data_q;
  
  // Register block
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      baud_rate_q <= '0;
      tx_data_q   <= '0;
    end else begin
      baud_rate_q <= baud_rate_d;
      tx_data_q   <= tx_data_d;
    end
  end

  always_comb begin 
    rx_fifo_rd_en_s = 1'b0;
    tx_fifo_wr_en_s = 1'b0;
    baud_rate_d = baud_rate_q;
    tx_data_d   = tx_data_q;
    bus_rdata_o = '0;

    unique case (bus_addr_i[1:0])
      2'b00: begin 
        if (bus_wr_en_i) begin
          baud_rate_d = bus_wdata_i; 
        end else begin
          bus_rdata_o = baud_rate_q;
        end
      end
      2'b01: bus_rdata_o = status_reg;
      2'b10: begin
        rx_fifo_rd_en_s = 1'b1;
        bus_rdata_o = BusDataWidth'(rx_fifo_rd_data_s);           
      end
      2'b11: begin 
        if (bus_wr_en_i) begin
          tx_fifo_wr_en_s = 1'b1; 
          tx_data_d = bus_wdata_i[7:0]; 
        end
      end
      default: ;
    endcase
  end

  baud_gen #(
    .ClockFrequency(ClockFrequency),
    .OverSampleRate(OverSampleRate)
  ) baud_generator (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .rx_busy_i(rx_busy_s),
    .tx_busy_i(tx_busy_s),
    .baud_sel_i(baud_sel_s),
    .baud_clk_o(baud_clk_s)
  );

  uart_rx #(
    .DataWidth(UartDataWidth)
  ) uart_reciever (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .baud_clk_i(baud_clk_s),
    .rxd_i(rxd_i),
    .valid_o(rx_valid_s),
    .busy_o(rx_busy_r),
    .data_o(rx_data_s)
  );

  fifo #(
    .DataWidth(UartDataWidth),
    .Depth(FifoDepth)
  ) recieve_fifo (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .rd_en_i(rx_fifo_rd_en_s),
    .wr_en_i(rx_valid_s),
    .wr_data_i(rx_data_s),
    .full_o(rx_fifo_full_s),
    .empty_o(rx_fifo_empty_s),
    .rd_data_o(rx_fifo_rd_data_s) 
  );

  fifo #(
    .DataWidth(UartDataWidth),
    .Depth(FifoDepth)
  ) transmit_fifo (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .wr_en_i(tx_fifo_wr_en_s),
    .rd_en_i(1'b0),                     // Tie to ground?
    .wr_data_i(tx_data_q),
    .full_o(tx_fifo_full_s),
    .empty_o(tx_fifo_empty_s),
    .rd_data_o(tx_fifo_rd_data_s)
  );

  uart_tx #(
    .DataWidth(UartDataWidth)
  ) uart_transmitter (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .baud_clk_i(baud_clk_s),
    .dv_i(tx_valid_s),
    .data_i(tx_fifo_rd_data_s),
    .txd_o(txd_o), 
    .busy_o(tx_busy_s)
  );

endmodule
