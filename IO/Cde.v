`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2022 07:52:47 PM
// Design Name: 
// Module Name: Cde
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

module Cde(
    input clk,
    input [15:0] sw,
    input btnU,
    input btnD,
    input btnL,
    input btnR,
    input btnC,
    output [15:0] led,
    output [6:0] seg,
    output dp,
    output [3:0] an,
    output RsTx
    );
    
    ////////////////////////////////
    // Generate Clocks
    ////////////////////////////////

    // Generate 9600 clock using PLL
    wire clkPll;
    wire locked;
    wire rst;
    Pll96 pll( .clk(clk), .clk9600(clkPll), .locked(locked), .rst(rst) );

    // Generate 9600 clock using PWM
    wire clkPwm;
    localparam PWM_HI  =  5208;
    localparam PWM_RTS = 10417;
    Pwm pwm( .clk(clk), .pwmHi(PWM_HI), .pwmRst(PWM_RTS), .pwm(clkPwm) );
    
    ////////////////////////////////
    // Generate UART
    ////////////////////////////////
    
    // 9600 baud uart
    wire clk_U;
    assign clk_U = clkPwm;
    reg [7:0] dI_U = 0;
    reg wrEn_U = 0;
    wire rdy_U;
    UartTx uart( .clk(clk_U), .txByte(dI_U), .txBit(RsTx), .txTrig(wrEn_U), .rdy(rdy_U) );
    
    ////////////////////////////////
    // Generate FIFOs
    ////////////////////////////////
    
    // Fifo A
    wire almostEmpty_A;
    wire almostFull_A;
    wire [8:0] dO_A;
    wire empty_A;
    wire full_A;
    wire [10:0] rdCount_A;
    wire rdErr_A;
    wire [10:0] wrCount_A;
    wire wrError_A;
    reg [8:0] dI_A;
    reg rdEn_A = 0;
    reg wrEn_A = 0;
    wire clk_A;
    assign clk_A = clk;
    Fifo fifo_A( .almostEmpty(almostEmpty_A), .almostFull(almostFull_A), .dO(dO_A),
        .empty(empty_A), .full(full_A), .rdCount(rdCount_A), .rdErr(rdErr_A),
        .wrCount(wrCount_A), .wrError(wrError_A), .dI(dI_A), .rdClk(clk_U), .rdEn(rdEn_A),
        .wrClk(clk_A), .wrEn(wrEn_A) );
    
    // Fifo B
    wire almostEmpty_B;
    wire almostFull_B;
    wire [8:0] dO_B;
    wire empty_B;
    wire full_B;
    wire [10:0] rdCount_B;
    wire rdErr_B;
    wire [10:0] wrCount_B;
    wire wrError_B;
    reg [8:0] dI_B;
    reg rdEn_B = 0;
    reg wrEn_B = 0;
    wire clk_B;
    assign clk_B = clk;
    Fifo fifo_B( .almostEmpty(almostEmpty_B), .almostFull(almostFull_B), .dO(dO_B),
        .empty(empty_B), .full(full_B), .rdCount(rdCount_B), .rdErr(rdErr_B),
        .wrCount(wrCount_B), .wrError(wrError_B), .dI(dI_B), .rdClk(clk_U), .rdEn(rdEn_B),
        .wrClk(clk_B), .wrEn(wrEn_B) );

    ////////////////////////////////
    // Generate 7-segment deisplay
    ////////////////////////////////
    
    // Generate 7-degment display
    reg [1:0] dispDig = 0;
    wire [3:0] dispDot;
    reg [3:0] dispD0;
    reg [3:0] dispD1;
    reg [3:0] dispD2;
    reg [3:0] dispD3;
    always @ (posedge(clk_U)) dispDig <= dispDig+1;
    DisplayDigits digits( .digit(dispDig), .d0({dispDot[0],dispD0}), .d1({dispDot[1],dispD1}),
        .d2({dispDot[2],dispD2}), .d3({dispDot[3],dispD3}), .dp(dp), .seg(seg), .an(an) );
        
    ////////////////////////////////
    // Generate debounced buttons
    ////////////////////////////////
    
    // Debounced buttons
    wire [4:0] btnDb;
    wire [4:0] btnDbDly;
    reg [7:0] btnDbCnt = 20;
    ButtonDebounce bd( .clk(clk), .btnIn({btnU, btnD, btnL, btnR, btnC}),
        .btnDb(btnDb), .btnDbDly(btnDbDly), .dbCount(btnDbCnt) );
        
    ////////////////////////////////
    // Switch inteface
    ////////////////////////////////
    
    // Switch modes
    reg rdA = 0;
    reg rdB = 0;
    reg wrA = 0;
    reg wrB = 0;
    reg wrU = 0;
    always @ (posedge(clk)) begin
        if (!sw[0] && !sw[1]) begin
            wrA = 0;
            wrB = 0;
            wrU = 1;
            if (btnDot<2) begin
                rdA = 1;
                rdB = 0;
            end else begin
                rdA = 0;
                rdB = 1;
            end
        end else if (sw[0] && !sw[1]) begin
            wrA = 1;
            wrB = 0;
            wrU = 0;
            if (btnDot<2) begin
                rdA = 0;
                rdB = 0;
            end else begin
                rdA = 0;
                rdB = 1;
            end
        end else if (!sw[0] && sw[1]) begin
            wrA = 0;
            wrB = 1;
            wrU = 0;
            if (btnDot<2) begin
                rdA = 1;
                rdB = 0;
            end else begin
                rdA = 0;
                rdB = 0;
            end
        end else if (sw[0] && sw[1]) begin
            rdA = 0;
            rdB = 0;
            wrU = 0;
            if (btnDot<2) begin
                wrA = 1;
                wrB = 0;
            end else begin
                wrA = 0;
                wrB = 1;
            end
        end
    end
    
    // Display modes
    assign led[0] = rdA;
    assign led[1] = rdB;
    assign led[2] = wrA;
    assign led[3] = wrB;
    assign led[4] = wrU;
    
    ////////////////////////////////
    // Button interface
    ////////////////////////////////
    
    // Left right interface
    wire btnLr = btnDbDly[1] | btnDbDly[2];
    reg [1:0] btnDot = 0;
    always @ (posedge(btnLr)) begin
        if (btnDb[1])
            btnDot <= btnDot-1;
        else if (btnDb[2])
            btnDot <= btnDot+1;
    end
    
    // Up down interface
    wire btnUd = btnDbDly[3] | btnDbDly[4];
    reg [3:0] digVal0 = 0;
    reg [3:0] digVal1 = 0;
    wire dig0;
    assign dig0 = (btnDot==0 || btnDot==2);
    always @ (posedge(btnUd)) begin
        if (btnDb[3]) begin
            if ( dig0 )
                digVal0 <= digVal0 - 1;
            else
                digVal1 <= digVal1 - 1;
        end else if (btnDb[4]) begin
            if ( dig0 )
                digVal0 <= digVal0 + 1;
            else
                digVal1 <= digVal1 + 1;
        end
    end
    
    // Center interface
    reg [7:0] clkState_A = 0;
    reg wrBreq_A = 0;
    reg rdAreq_A = 0;
    reg wrAack_A = 0;
    reg wrUreq_A = 0;
    always @ (negedge(clk_A)) begin
        case (clkState_A)
            0 : begin
                if ( wrA && (btnDot < 2) && btnDb[0] && !full_A  ) begin
                    dI_A <= {1'b1,digVal1,digVal0};
                    wrEn_A <= 1;
                    clkState_A <= 2;
                end else if ( rdA && (btnDot < 2) && wrB && btnDb[0] && !empty_A ) begin
                    wrBreq_A <= 1;
                    clkState_A <= 4;
                end else if ( wrAreq_B ) begin
                    dI_A <= dO_B;
                    wrEn_A <= 1;
                    clkState_A <= 7;
                end else if ( rdA && (btnDot < 2) && wrU && btnDb[0] && !empty_A ) begin
                    wrUreq_A <= 1;
                    clkState_A <= 9;
                end
            end
            
            // Input from digit
            2 : begin
                wrEn_A <= 0;
                clkState_A <= 3;
            end
            3 : begin
                if ( !btnDb[0] ) clkState_A <= 0;
            end
            
            // Output to B
            4 : begin
                if ( wrBack_B ) begin
                    wrBreq_A <= 0;
                    rdAreq_A <= 1;
                    clkState_A <= 5;
                end
            end
            5 : begin
                if ( rdAack_U && !wrBack_B ) begin
                    rdAreq_A <= 0;
                    clkState_A <= 6;
                end
            end
            6 : begin
                if ( !rdAack_U ) begin
                    clkState_A <= 0;
                end
            end
            
            // Input from B
            7 : begin
                wrEn_A <= 0;
                wrAack_A <= 1;
                clkState_A <= 8;
            end
            8 : begin
                if ( !wrAreq_B ) begin
                    wrAack_A <= 0;
                    clkState_A <= 0;
                end
            end
            
            // Output to U
            9 : begin
                if ( wrUack_U ) begin
                    wrUreq_A <= 0;
                    rdAreq_A <= 1;
                    clkState_A <= 10;
                end
            end
            10 : begin
                if ( !wrUack_U & rdAack_U ) begin
                    rdAreq_A <= 0;
                    clkState_A <= 11;
                end
            end
            11 : begin
                if ( !rdAack_U ) begin
                    clkState_A <= 0;
                end
            end                   
        endcase
    end
    reg [7:0] clkState_B = 0;
    reg wrAreq_B = 0;
    reg rdBreq_B = 0;
    reg wrBack_B = 0;
    reg wrUreq_B = 0;
    always @ (negedge(clk_B)) begin
        case (clkState_B)
            0 : begin
                if ( wrB && (btnDot > 1) && btnDb[0] && !full_B ) begin
                    dI_B <= {1'b1,digVal1,digVal0};
                    wrEn_B <= 1;
                    clkState_B <= 2;
                end else if ( rdB && (btnDot > 1) && wrA && btnDb[0] && !empty_B ) begin
                    wrAreq_B <= 1;
                    clkState_B <= 4;
                end else if ( wrBreq_A ) begin
                    dI_B <= dO_A;
                    wrEn_B <= 1;
                    clkState_B <= 7;
                end else if ( rdB && (btnDot >1) && wrU && btnDb[0] && !empty_B ) begin
                    wrUreq_B <= 1;
                    clkState_B <= 9;
                end
            end
            
            // Input from digit
            2 : begin
                wrEn_B <= 0;
                clkState_B <= 3;
            end
            3 : begin
                if ( !btnDb[0] ) clkState_B <= 0;
            end
            
            // Output to A
            4 : begin
                if ( wrAack_A ) begin
                    wrAreq_B <= 0;
                    rdBreq_B <= 1;
                    clkState_B <= 5;
                end
            end
            5 : begin
                if ( rdBack_U && !wrAack_A ) begin
                    rdBreq_B <= 0;
                    clkState_B <= 6;
                end
            end
            6 : begin
                if ( !rdBack_U ) begin
                    clkState_B <= 0;
                end
            end

            // Input from A
            7 : begin
                wrEn_B <= 0;
                wrBack_B <= 1;
                clkState_B <= 8;
            end
            8 : begin
                if ( !wrBreq_A ) begin
                    wrBack_B <= 0;
                    clkState_B <= 0;
                end
            end
            
            // Output to U
            9 : begin
                if ( wrUack_U ) begin
                    wrUreq_B <= 0;
                    rdBreq_B <= 1;
                    clkState_B <= 10;
                end
            end
            10 : begin
                if ( !wrUack_U & rdBack_U ) begin
                    rdBreq_B <= 0;
                    clkState_B <= 11;
                end
            end
            11 : begin
                if ( !rdBack_U ) begin
                    clkState_B <= 0;
                end
            end
        endcase 
    end
    reg [7:0] clkState_U = 0;
    reg rdAack_U = 0;
    reg rdBack_U = 0;
    reg wrUack_U = 0;
    always @ (negedge(clk_U)) begin
        case (clkState_U)
            0 : begin
                if ( rdAreq_A ) begin
                    rdEn_A <= 1;
                    clkState_U <= 1;
                end else if ( rdBreq_B ) begin
                    rdEn_B <= 1;
                    clkState_U <= 3;
                end else if ( wrUreq_A & rdy_U ) begin
                    dI_U <= dO_A[7:0];
                    wrEn_U <= 1;
                    clkState_U <= 5;
                end else if ( wrUreq_B & rdy_U ) begin
                    dI_U <= dO_B[7:0];
                    wrEn_U <= 1;
                    clkState_U <= 7;
                end
            end
            
            // Read A
            1 : begin
                rdEn_A <= 0;
                rdAack_U <= 1;
                clkState_U <= 2;
            end
            2 : begin
                if ( !rdAreq_A ) begin
                    rdAack_U <= 0;
                    clkState_U <= 0;
                end
            end
            
            // Read B
            3 : begin
                rdEn_B <= 0;
                rdBack_U <= 1;
                clkState_U <= 4;
            end
            4 : begin
                if ( !rdBreq_B ) begin
                    rdBack_U <= 0;
                    clkState_U <= 0;
                end
            end
            
            // Write from A
            5 : begin
                wrEn_U <= 0;
                wrUack_U <= 1;
                clkState_U <= 6;
            end
            6 : begin
                if ( !wrUreq_A ) begin
                    wrUack_U <= 0;
                    clkState_U <= 0;
                end
            end
            
            // Write from B
            7 : begin
                wrEn_U <= 0;
                wrUack_U <= 1;
                clkState_U <= 8;
            end
            8 : begin
                if ( !wrUreq_B ) begin
                    wrUack_U <= 0;
                    clkState_U <= 0;
                end
            end
        endcase
    end
    assign led[15] = rdBack_U;
    assign led[14] = rdBreq_B;
    assign led[13] = rdAack_U;
    assign led[12] = rdAreq_A;
    assign led[11] = wrAack_A;
    assign led[10] = wrAreq_B;
    assign led[9] = wrBack_B;
    assign led[8] = wrBreq_A;
    assign led[7] = wrUreq_A;
    assign led[6] = wrUreq_B;
    assign led[5] = wrUack_U;
          
    // Update 7-digit display
    always @ (posedge(clk)) begin
        if ( btnDot < 2 ) begin
            if ( wrA ) begin
                dispD0 <= digVal0;
                dispD1 <= digVal1;
            end else begin
                dispD0 <= dO_A[3:0];
                dispD1 <= dO_A[7:4];
            end
            if ( wrA ) begin
                dispD2 <= wrCount_A[3:0];
                dispD3 <= wrCount_A[7:4];
            end else if ( rdA & wrB ) begin
                dispD2 <= wrCount_B[3:0];
                dispD3 <= wrCount_B[7:4];
            end else begin
                dispD2 <= rdCount_A[3:0];
                dispD3 <= rdCount_A[7:4];
            end
        end else begin
            if ( wrB ) begin
                dispD0 <= wrCount_B[3:0];
                dispD1 <= wrCount_B[7:4];
            end else if ( rdB & wrA ) begin
                dispD0 <= wrCount_A[3:0];
                dispD1 <= wrCount_A[7:4];
            end else begin
                dispD0 <= rdCount_B[3:0];
                dispD1 <= rdCount_B[7:4];
            end
            if ( wrB ) begin
                dispD2 <= digVal0;
                dispD3 <= digVal1;
            end else begin
                dispD2 <= dO_B[3:0];
                dispD3 <= dO_B[7:4];
            end
        end
    end
    
    // Update dot display
    wire dispDotAnd;
    assign  dispDotAnd = ~(btnDb[3] | btnDb[4]);
    wire dispDotOr;
    assign  dispDotOr = btnDb[0];
    assign dispDot[3] = ((btnDot == 3) | dispDotOr) & dispDotAnd;
    assign dispDot[2] = ((btnDot == 2) | dispDotOr) & dispDotAnd;
    assign dispDot[1] = ((btnDot == 1) | dispDotOr) & dispDotAnd;
    assign dispDot[0] = ((btnDot == 0) | dispDotOr) & dispDotAnd;
    
endmodule