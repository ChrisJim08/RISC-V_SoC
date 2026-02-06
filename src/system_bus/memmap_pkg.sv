//  Package: memmap_pkg
//
package memmap_pkg;
  
// localparams

  localparam int unsigned Num_Targets = 2;
  
// Exclusive limits

// RAM
  localparam int unsigned           RamIdx    = 0;
  localparam logic [Num_Targets-1:0] RamSelOneHotId = Num_Targets'('b1);
  localparam logic [31:0] RamBase   = 32'h0000_0000;
  localparam logic [31:0] RamLimit  = 32'h0001_0000; 

// UART
  localparam int unsigned UartIdx   = 1;
  localparam logic [Num_Targets-1:0] UartSelOneHotId = Num_Targets'('b10);
  localparam logic [31:0] UartBase  = 32'h1000_1000;
  localparam logic [31:0] UartLimit = 32'h1000_2000; 
  localparam logic [19:0] UartKey   = 20'h1000_1;

// Timer (TBI (To be implemented))
  /*
  localparam int unsigned TimerIdx  = 2;
  localparam logic [NumTargets-1:0] UartSelOneHotId = NumTargets'('b100);
  localparam logic [31:0] TimerBase  = 32'h1000_2000;
  localparam logic [31:0] TimerLimit = 32'h1000_3000; 
  localparam logic [19:0] TimerKey   = 20'h1000_2;
  */
  
endpackage
