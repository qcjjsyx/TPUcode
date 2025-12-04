//-----------------------------------------------
//	module name: delay1U
//	author: Anping HE (heap@lzu.edu.cn)
//	version: 1st version (2021-11-13)
//	description: 
//		delay1U
//  tech: xilinx fpga
//----------------------------------------------
`timescale 1ns / 1ps

(* dont_touch="true" *)module freeSetDelay#(
    parameter integer N = 4  // 默认 4 级延时单元
)(
    input  wire inR,
    output wire outR,
    input  wire rst
);

    wire [0:N] stage;  // 中间连接信号
    assign stage[0] = inR;

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : delay_chain
            // 每一级使用 dont_touch，防止综合优化
            (* dont_touch = "true" *)
            delay1U u_delay_inst (
                .inR(stage[i]),
                .outR(stage[i+1]),
                .rst(rst)
            );
        end
    endgenerate

    assign outR = stage[N];

endmodule