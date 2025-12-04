`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2023/06/26 10:00:04
// Design Name: dalay2Unit    ->    delay2U
// Module Name: delay2U
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


(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)module delay2U(
    inR, outR,rst
    );
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input inR;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input rst;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output outR;
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire outR0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)delay1U delay0(.inR(inR), .outR(outR0),.rst(rst));
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)delay1U delay1(.inR(outR0), .outR(outR),.rst(rst));
    
endmodule
