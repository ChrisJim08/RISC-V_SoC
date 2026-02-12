// Bus adapter enabling my mem block to interface with the bus
module ram_bus_adapter #(
  parameter DataWidth    = 32,
  parameter AddressWidth = 32
) (
// System
  input logic clk_i,
  input logic rst_i,

// Memory block
  output logic    mem_wr_en_o,
  output logic [AddressWidth-1:0] mem_addr_o,
  output logic [DataWidth-1:0]    mem_wr_data_o,
  input  logic [DataWidth-1:0]    mem_r_data_i,

// Bus fabric
  bus_if.target bus_if
);

  logic aw_hs;
  logic w_hs;
  logic b_hs;
  logic ar_hs;
  logic r_hs;

  logic aw_seen;
  logic w_seen;

  logic [AddressWidth-1:0] aw_addr_q;
  logic [DataWidth-1:0]    w_data_q;
  logic [AddressWidth-1:0] ar_addr_q;

  logic wr_inflight;
  logic rd_inflight;

  assign aw_hs = bus_if.aw_valid && bus_if.aw_ready;
  assign w_hs  = bus_if.w_valid  && bus_if.w_ready;
  assign b_hs  = bus_if.b_ready  && bus_if.b_valid;
  assign ar_hs = bus_if.ar_valid && bus_if.ar_ready;
  assign r_hs  = bus_if.r_ready  && bus_if.r_valid;

  assign bus_if.aw_ready = !aw_seen     && !rd_inflight;
  assign bus_if.w_ready  = !w_seen      && !rd_inflight;
  assign bus_if.ar_ready = !wr_inflight && !rd_inflight;

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      aw_seen     <= 1'b0;
      w_seen      <= 1'b0;
      
      wr_inflight <= 1'b0;
      rd_inflight <= 1'b0;

      bus_if.b_valid <= 1'b0;
      bus_if.r_valid <= 1'b0;
    end
    else begin

      if (aw_hs) begin
        aw_addr_q <= bus_if.aw_addr;
        aw_seen <= 1'b1;
      end
      if (w_hs) begin 
        w_data_q  <= bus_if.w_data;
        w_seen  <= 1'b1; 
      end

      if ((aw_hs || aw_seen) && (w_hs || w_seen) && !wr_inflight) begin
        aw_seen        <= 1'b0;
        w_seen         <= 1'b0;
        wr_inflight    <= 1'b1;
        bus_if.b_valid <= 1'b1; 
      end

      if (b_hs) begin
        bus_if.b_valid <= 1'b0;
        wr_inflight    <= 1'b0;
      end

      if (ar_hs) begin
        rd_inflight    <= 1'b1;
        ar_addr_q      <= bus_if.ar_addr; 
        bus_if.r_valid <= 1'b1;
      end

      if (r_hs) begin
        rd_inflight    <= 1'b0;
        bus_if.r_valid <= 1'b0;
      end
    end
  end

  // routing
  always_comb begin
    mem_wr_en_o   = 1'b0;
    mem_addr_o    = '0;
    mem_wr_data_o = '0;
    bus_if.r_data = '0;

    if ((aw_seen || aw_hs) && (w_seen || w_hs)) begin
      mem_wr_en_o   = 1'b1; 
      mem_addr_o    = aw_hs ? bus_if.aw_addr : aw_addr_q;
      mem_wr_data_o = w_hs  ? bus_if.w_data  : w_data_q;
    end
    else if (rd_inflight || ar_hs) begin
      mem_addr_o    = ar_hs ? bus_if.ar_addr : ar_addr_q;
      bus_if.r_data = mem_r_data_i;                         // buffer r_data for mem's synchrous read TODO
    end
  end
  
endmodule