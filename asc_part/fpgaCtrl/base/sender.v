//-----------------------------------------------
//	module name: sender
//	author: Tong Fu
//	version: 1st version (2023-06-15)
//	description: 
//		standard click  
//		tech: xilinx fpga
//----------------------------------------------
`timescale 1ns / 1ps

module sender(
    input       i_drive     ,
    input       i_free      ,
    output      o_free      ,
    output      outR        ,
    input       rst     
);

contTap  u_contTap (
    .trig           ( i_drive   ),
    .req            ( outR      ),
    .rst            ( rst       )
);

LUT1 #(.INIT(2'b10)) reply_delay
(
    .O              ( o_free    ),
    .I0             ( i_free    )
);

endmodule
