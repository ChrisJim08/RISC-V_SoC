// Bus adapter enabling my mem block to interface with the bus
module ram_bus_adapter #(
  parameter DataWidth    = 32,
  parameter AddressWidth = 32
) (
// System
  input logic clk_i,
  input logic rst_i,

// Memory block
  output logic mem_addr_o,
  output logic mem_wr_data_o,
  output logic mem_wr_en_o,
  input  logic mem_r_data_i,

// Bus fabric
  bus_if.target bus_if
);

// States
  typedef enum { 
    Idle, WrInFlight, RdInFlight
  } bus_state_e;

// State register
  bus_state_e state_reg;
  bus_state_e next_state;

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      
    end
    else begin
      if (bus_if.w_valid) begin
        bus_if.w_ready <= 1'b1;
        
      end
      
    end
  end

always_comb begin
  if ()
end


  
endmodule