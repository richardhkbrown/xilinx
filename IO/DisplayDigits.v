`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2022 08:06:28 PM
// Design Name: 
// Module Name: DisplayDigits
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

module DisplayDigits(
    input [1:0] digit,
    input [4:0] d0,
    input [4:0] d1,
    input [4:0] d2,
    input [4:0] d3,
    output dp,
    output [6:0] seg,
    output [3:0] an );
    
    reg dpReg;
    reg [6:0] segReg;
    reg [3:0] anReg;
    assign dp = ~dpReg;
    assign seg = segReg;
    assign an = anReg;
    
    reg [3:0] digReg;
    
    always @* begin
    
        case (digit)
            0 : begin
                dpReg <= d0[4];
                digReg <= d0[3:0];
                anReg <= 4'b1110;
            end
            1 : begin
                dpReg <= d1[4];
                digReg <= d1[3:0];
                anReg <= 4'b1101;
            end
            2 : begin
                dpReg <= d2[4];
                digReg <= d2[3:0];
                anReg <= 4'b1011;
            end
            3 : begin
                dpReg <= d3[4];
                digReg <= d3[3:0];
                anReg <= 4'b0111;
            end
        endcase
        
        case (digReg)
            4'b0000 : segReg <= 7'b1000000; // 0
            4'b0001 : segReg <= 7'b1111001; // 1
            4'b0010 : segReg <= 7'b0100100; // 2
            4'b0011 : segReg <= 7'b0110000; // 3
            4'b0100 : segReg <= 7'b0011001; // 4
            4'b0101 : segReg <= 7'b0010010; // 5
            4'b0110 : segReg <= 7'b0000010; // 6
            4'b0111 : segReg <= 7'b1111000; // 7
            4'b1000 : segReg <= 7'b0000000; // 8
            4'b1001 : segReg <= 7'b0010000; // 9
            4'b1010 : segReg <= 7'b0001000; // a
            4'b1011 : segReg <= 7'b0000011; // b
            4'b1100 : segReg <= 7'b0100111; // c
            4'b1101 : segReg <= 7'b0100001; // d
            4'b1110 : segReg <= 7'b0000110; // e
            4'b1111 : segReg <= 7'b0001110; // f
        endcase
            
    end
    
endmodule
