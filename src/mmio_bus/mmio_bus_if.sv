//  Interface: mmio_bus_if
//
interface mmio_bus_if #(
  parameter int unsigned DataWidth = 32
)(
  input logic clk_i,
  input logic rst_i
);

// Write Channels

  // Write address (AW) channel
  logic aw_valid;
  logic aw_ready;
  logic [DataWidth-1:0] aw_addr;

  // Write data (W) channel
  logic w_valid;
  logic w_ready;
  logic [DataWidth-1:0] w_data;
  logic w_strb;

  // Write response (B) channel
  logic b_valid;
  logic b_ready;
  logic [1:0] b_resp;

// Read Channels

  // Read address (AR) channel
  logic ar_valid;
  logic ar_ready;
  logic [DataWidth-1:0] ar_addr;

  // Read data (R) channel
  logic r_valid;
  lgoci r_ready;
  logic [DataWidth-1:0] r_data;
  logic [1:0] r_resp;

  modport manager (
  input input_ports,
  output output_ports
  );

  modport subordinate (
  input input_ports,
  output output_ports
  );

endinterface: mmio_bus_if

