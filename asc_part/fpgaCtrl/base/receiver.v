//-----------------------------------------------
//	module name: receiver
//	author: Tong Fu
//	version: 1st version (2023-06-15)
//	description: 
//		permit sink  
//		tech: xilinx fpga
//-----------------------------------------------
`timescale 1ns / 1ps

(* dont_touch="true" *)module receiver(
    input           inR         ,
    input           i_freeNext  ,
    output  reg     inA         ,
    input           rst
);

always@(posedge i_freeNext or negedge rst) begin
    if(!rst)
        inA <= 1'b0;
    else
        inA <= inR;
end

endmodule
