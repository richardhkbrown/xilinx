`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2022 05:19:07 PM
// Design Name: 
// Module Name: Pwm
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

module Pwm(
    input clk,
    input [31:0] pwmHi,
    input [31:0] pwmRst,
    output pwm);
    
    reg pwmReg = 0;
    assign pwm = pwmReg;
    reg [31:0] count = 0;
    always @ (negedge(clk)) begin
        if ( count < pwmRst )
            count <= count + 1;
        else
            count <= 0;
    end
    always @ (posedge(clk)) begin
        if (count<pwmHi)
            pwmReg <= 1;
        else
            pwmReg <= 0;
    end

endmodule
