`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2023/06/26 10:00:04
// Module Name: delay16U
// Project Name: RCA
// Target Devices: FPGA
// Description: 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


(*dont_touch = "true"*)module delay16U(
    inR, outR, rst
    );
    input inR;
    output outR;
    input rst;
    
    wire outR0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)delay8U delay0(.inR(inR), .outR(outR0), .rst(rst));
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)delay8U delay1(.inR(outR0), .outR(outR), .rst(rst));
    
endmodule
