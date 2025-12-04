`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2023/06/26 10:00:04
// Design Name: dalay1Unit    ->    delay1U
// Module Name: delay1U
// Project Name: RCA
// Target Devices: FPGA
// Description: 本模块是fpga上使用的dalay1Unit改名为dalay1U（为了统一命名），
//              之前的LUT实现的延迟不好用且对资源消耗更大
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//只能delay inR outR初始时相同的情况

 (* dont_touch="true" *)module delay1U(
	inR, outR, rst
    );
	(* dont_touch="true" *) input   rst;
	(* dont_touch="true" *) input 	inR;
	(* dont_touch="true" *) output	outR;
	
	(* dont_touch="true" *) wire	  in_nor, out_delayed, out_tmp;
  (* dont_touch="true" *) reg     outR;

assign in_nor = out_delayed ^ inR;

always @(posedge in_nor or negedge rst)
begin
  if(!rst)
  outR <= 1'b0;
  else
  outR <= out_tmp;
end

assign out_tmp = ~outR;
assign out_delayed = outR;

endmodule
