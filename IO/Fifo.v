`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2022 07:48:53 PM
// Design Name: 
// Module Name: Fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Fifo(
    output almostEmpty,    // 1-bit output almost empty
    output almostFull,     // 1-bit output almost full
    output [8:0] dO,       // Output data, width defined by DATA_WIDTH parameter
    output empty,          // 1-bit output empty
    output full,           // 1-bit output full
    output [10:0] rdCount, // Output read count, width determined by FIFO depth
    output rdErr,          // 1-bit output read error
    output [10:0] wrCount, // Output write count, width determined by FIFO depth
    output wrError,        // 1-bit output write error
    input [8:0] dI,        // Input data, width defined by DATA_WIDTH parameter
    input rdClk,           // 1-bit input read clock
    input rdEn,            // 1-bit input read enable
    input wrClk,           // 1-bit input write clock
    input wrEn );          // 1-bit input write enable

    // Fifo initialization reset flag
    parameter RES_WIDTH = 7;
    reg [RES_WIDTH-1:0] resetRd = {RES_WIDTH{1'b1}};
    reg [RES_WIDTH-1:0] resetWr = {RES_WIDTH{1'b1}};
    always @ (posedge rdClk) resetRd <= {resetRd[RES_WIDTH-2:0],1'b0};
    always @ (posedge wrClk) resetWr <= {resetWr[RES_WIDTH-2:0],1'b0};
    wire rst;
    assign rst = resetRd[RES_WIDTH-1] | resetWr[RES_WIDTH-1];
    
    wire wrEn2;
    wire rdEn2;
    assign wrEn2 = wrEn & !rst & !full;
    assign rdEn2 = rdEn & !rst & !empty;
    
// FIFO_DUALCLOCK_MACRO : In order to incorporate this function into the design,
//     Verilog          : the following instance declaration needs to be placed
//    instance          : in the body of the design code.  The instance name
//   declaration        : (FIFO_DUALCLOCK_MACRO_inst) and/or the port declarations within the
//      code            : parenthesis may be changed to properly reference and
//                      : connect this function to the design.  All inputs
//                      : and outputs must be connected.

//  <-----Cut code below this line---->

   // FIFO_DUALCLOCK_MACRO: Dual Clock First-In, First-Out (FIFO) RAM Buffer
   //                       Artix-7
   // Xilinx HDL Language Template, version 2021.2

   /////////////////////////////////////////////////////////////////
   // DATA_WIDTH | FIFO_SIZE | FIFO Depth | RDCOUNT/WRCOUNT Width //
   // ===========|===========|============|=======================//
   //   37-72    |  "36Kb"   |     512    |         9-bit         //
   //   19-36    |  "36Kb"   |    1024    |        10-bit         //
   //   19-36    |  "18Kb"   |     512    |         9-bit         //
   //   10-18    |  "36Kb"   |    2048    |        11-bit         //
   //   10-18    |  "18Kb"   |    1024    |        10-bit         //
   //    5-9     |  "36Kb"   |    4096    |        12-bit         //
   //    5-9     |  "18Kb"   |    2048    |        11-bit         //
   //    1-4     |  "36Kb"   |    8192    |        13-bit         //
   //    1-4     |  "18Kb"   |    4096    |        12-bit         //
   /////////////////////////////////////////////////////////////////

   FIFO_DUALCLOCK_MACRO  #(
      .ALMOST_EMPTY_OFFSET(9'h080), // Sets the almost empty threshold
      .ALMOST_FULL_OFFSET(9'h080),  // Sets almost full threshold
      .DATA_WIDTH(9),   // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
      .DEVICE("7SERIES"),  // Target device: "7SERIES" 
      .FIFO_SIZE ("18Kb"), // Target BRAM: "18Kb" or "36Kb" 
      .FIRST_WORD_FALL_THROUGH ("TRUE") // Sets the FIFO FWFT to "TRUE" or "FALSE" 
   ) FIFO_DUALCLOCK_MACRO_inst (
      .ALMOSTEMPTY(almostEmpty), // 1-bit output almost empty
      .ALMOSTFULL(almostFull),   // 1-bit output almost full
      .DO(dO),                   // Output data, width defined by DATA_WIDTH parameter
      .EMPTY(empty),             // 1-bit output empty
      .FULL(full),               // 1-bit output full
      .RDCOUNT(rdCount),         // Output read count, width determined by FIFO depth
      .RDERR(rdErr),             // 1-bit output read error
      .WRCOUNT(wrCount),         // Output write count, width determined by FIFO depth
      .WRERR(wrError),           // 1-bit output write error
      .DI(dI),                   // Input data, width defined by DATA_WIDTH parameter
      .RDCLK(rdClk),             // 1-bit input read clock
      .RDEN(rdEn2),               // 1-bit input read enable
      .RST(rst),                 // 1-bit input reset
      .WRCLK(wrClk),             // 1-bit input write clock
      .WREN(wrEn2)                // 1-bit input write enable
   );

   // End of FIFO_DUALCLOCK_MACRO_inst instantiation

endmodule
