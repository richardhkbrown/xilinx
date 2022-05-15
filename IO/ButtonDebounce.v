`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2022 08:04:27 PM
// Design Name: 
// Module Name: ButtonDebounce
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


module ButtonDebounce(
    input clk,
    input [4:0] btnIn,
    output [4:0] btnDb,
    output [4:0] btnDbDly,
    input [7:0] dbCount );
        
    reg [7:0] btnUcnt = 0;
    reg [7:0] btnDcnt = 0;
    reg [7:0] btnLcnt = 0;
    reg [7:0] btnRcnt = 0;
    reg [7:0] btnCcnt = 0;
    
    reg [4:0] btnDbReg = 0; 
    assign btnDb = btnDbReg;
    
    parameter DELAY = 1;
    reg [DELAY:0] btnUdly = 0;
    reg [DELAY:0] btnDdly = 0;
    reg [DELAY:0] btnLdly = 0;
    reg [DELAY:0] btnRdly = 0;
    reg [DELAY:0] btnCdly = 0;
    assign btnDbDly = {btnCdly[DELAY],btnRdly[DELAY],btnLdly[DELAY],btnDdly[DELAY],btnUdly[DELAY]};

    always @ (posedge(clk)) begin
        btnUdly = {btnUdly[DELAY-1:0],btnDbReg[0]};
        btnDdly = {btnDdly[DELAY-1:0],btnDbReg[1]};
        btnLdly = {btnLdly[DELAY-1:0],btnDbReg[2]};
        btnRdly = {btnRdly[DELAY-1:0],btnDbReg[3]};
        btnCdly = {btnCdly[DELAY-1:0],btnDbReg[4]};
        if ( btnIn[4] ) begin
            btnUcnt <= dbCount;
        end else begin
            if ( btnUcnt > 0 )
                btnUcnt <= btnUcnt - 1;
        end
        if ( btnIn[3] ) begin
            btnDcnt <= dbCount;
        end else begin
            if ( btnDcnt > 0 )
                btnDcnt <= btnDcnt - 1;
        end
        if ( btnIn[2] ) begin
            btnLcnt <= dbCount;
        end else begin
            if ( btnLcnt > 0 )
                btnLcnt <= btnLcnt - 1;
        end
        if ( btnIn[1] ) begin
            btnRcnt <= dbCount;
        end else begin
            if ( btnRcnt > 0 )
                btnRcnt <= btnRcnt - 1;
        end
        if ( btnIn[0] ) begin
            btnCcnt <= dbCount;
        end else begin
            if ( btnCcnt > 0 )
                btnCcnt <= btnCcnt - 1;
        end
    end
    always @ (negedge(clk)) begin
        if ( btnUcnt > 0 )
            btnDbReg[4] <= 1;
        else
            btnDbReg[4] <= 0;
        if ( btnDcnt > 0 )
            btnDbReg[3] <= 1;
        else
            btnDbReg[3] <= 0;
        if ( btnLcnt > 0 )
            btnDbReg[2] <= 1;
        else
            btnDbReg[2] <= 0;
        if ( btnRcnt > 0 )
            btnDbReg[1] <= 1;
        else
            btnDbReg[1] <= 0;
        if ( btnCcnt > 0 )
            btnDbReg[0] <= 1;
        else
            btnDbReg[0] <= 0;
    end
    
 endmodule
