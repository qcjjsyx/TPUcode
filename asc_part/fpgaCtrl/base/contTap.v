//-----------------------------------------------
//	module name: contTap
//	author: Anping HE (heap@lzu.edu.cn)
//	version: 1st version (2021-11-13)
//	description: 
//		contTap
//  tech: xilinx fpga
//----------------------------------------------
`timescale 1ns / 1ps

(* dont_touch="true" *)module contTap(
    (*dont_touch = "yes"*)input           trig, 
    (*dont_touch = "yes"*)output  reg     req, 
    (*dont_touch = "yes"*)input           rst
);

always@(posedge trig or negedge rst) begin
    if(!rst)
        req <= 1'b0;
    else
        req <= !req;
end

endmodule
