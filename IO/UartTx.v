`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2022 08:02:10 PM
// Design Name: 
// Module Name: UartTx
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

module UartTx(
    input clk,
    input [7:0] txByte,
    output txBit,
    input txTrig,
    output rdy
    );
    
    reg [3:0] state = 0;
    reg [7:0] txByteLatch = 0;
    reg tx = 1;
    assign txBit = tx;
    reg rdyReg = 1;
    assign rdy = rdyReg;
    
    always @ (posedge clk) begin
        case (state)
            0 : begin
                if ( txTrig ) begin
                    txByteLatch = txByte;
                    tx <= 0;
                    rdyReg <= 0;
                    state <= 1;
                end
            end
            1: begin
                tx <= txByteLatch[0];
                state <= 2;
            end
            2: begin
                tx <= txByteLatch[1];
                state <= 3;
            end
            3: begin
                tx <= txByteLatch[2];
                state <= 4;
            end
            4: begin
                tx <= txByteLatch[3];
                state <= 5;
            end
            5: begin
                tx <= txByteLatch[4];
                state <= 6;
            end
            6: begin
                tx <= txByteLatch[5];
                state <= 7;
            end
            7: begin
                tx <= txByteLatch[6];
                state <= 8;
            end
            8: begin
                tx <= txByteLatch[7];
                state <= 9;
            end
            9: begin
                txByteLatch = 0;
                tx <= 1;
                state <= 10;
            end
            10: begin
                rdyReg <= 1;
                state <= 0;
            end
       endcase
       
    end
    
endmodule
