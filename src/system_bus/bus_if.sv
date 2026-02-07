//  Interface: bus_if
//
interface bus_if #(
  parameter  int unsigned AddressWidth = 32,
  parameter  int unsigned DataWidth    = 32,
  localparam int unsigned StrobeWidth  = DataWidth / 8
);

// Write Channels

  // Write address (AW) channel
  logic aw_valid;
  logic aw_ready;
  logic [AddressWidth-1:0] aw_addr;

  // Write data (W) channel
  logic w_valid;
  logic w_ready;
  logic [DataWidth-1:0]   w_data;
  logic [StrobeWidth-1:0] w_strb;

  // Write response (B) channel
  logic b_valid;
  logic b_ready;
  logic [1:0] b_resp;

// Read Channels

  // Read address (AR) channel
  logic ar_valid;
  logic ar_ready;
  logic [AddressWidth-1:0] ar_addr;

  // Read data (R) channel
  logic r_valid;
  logic r_ready;
  logic [DataWidth-1:0] r_data;
  logic [1:0] r_resp;

  modport initiator (
    input aw_ready, 
          w_ready, 
          b_valid, 
          b_resp, 
          ar_ready, 
          r_valid, 
          r_data, 
          r_resp,
    output aw_valid, 
           aw_addr, 
           w_valid, 
           w_data, 
           w_strb, 
           b_ready, 
           ar_valid, 
           ar_addr, 
           r_ready
  );

  modport target (
    input aw_valid, 
          aw_addr, 
          w_valid, 
          w_data, 
          w_strb, 
          b_ready, 
          ar_valid, 
          ar_addr, 
          r_ready,
    output aw_ready, 
           w_ready, 
           b_valid, 
           b_resp,
           ar_ready, 
           r_valid, 
           r_data, 
           r_resp
  );

  modport fabric_to_target (
    input aw_ready, 
          w_ready, 
          b_valid, 
          b_resp, 
          ar_ready, 
          r_valid, 
          r_data, 
          r_resp,
    output aw_valid, 
           aw_addr, 
           w_valid, 
           w_data, 
           w_strb, 
           b_ready, 
           ar_valid, 
           ar_addr, 
           r_ready
  );

  modport fabric_to_initiator (
    input aw_valid, 
          aw_addr, 
          w_valid, 
          w_data, 
          w_strb, 
          b_ready, 
          ar_valid, 
          ar_addr, 
          r_ready,
    output aw_ready, 
           w_ready, 
           b_valid, 
           b_resp,
           ar_ready, 
           r_valid, 
           r_data, 
           r_resp
  );
  
  generate
    if (DataWidth % 8 != 0) begin: datawidth_error
      initial begin
        $error("DataWidth (%0d) must be a multiple of 8", DataWidth);
      end
    end
  endgenerate

endinterface
