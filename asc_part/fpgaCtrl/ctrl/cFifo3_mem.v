//-----------------------------------------------
//	module name: clickfifo1
//	author: Tong Fu, Lingzhuang Zhang
//	version: 1st version (2022-11-15)
//-----------------------------------------------

`timescale 1ns / 1ps

module cFifo3_mem(
    // last -->
    (* dont_touch="true" *)input           i_drive,
    (* dont_touch="true" *)output          o_free,
    // --> next
    (* dont_touch="true" *)output          o_driveNext,
    (* dont_touch="true" *)input           i_freeNext,
    (* dont_touch="true" *)output  [2:0]   o_fire_3,
    // reset signal
    (* dont_touch="true" *)input           rst
);

wire [3:0]  w_outRRelay_4,w_outARelay_4;
wire        w_driveNext;

// pipeline
sender sender(
	.i_drive    ( i_drive           ),
	.o_free     ( o_free            ),
	.outR       ( w_outRRelay_4[0]  ),
	.i_free     ( w_driveNext       ),
	.rst        ( rst               )
);

wire w_relay0_delay;
delay3U relay0Delay (.inR(w_outRRelay_4[0]), .outR(w_relay0_delay), .rst(rst));

relay relay0(
	.inR        ( w_relay0_delay    ),
	.inA        ( w_outARelay_4[0]  ),
	.outR       ( w_outRRelay_4[1]  ),
	.outA       ( w_outARelay_4[1]  ),
	.fire       ( o_fire_3[0]       ),
	.rst        ( rst               )
);

wire w_relay1_delay;
delay3U relay1Delay (.inR(w_outRRelay_4[1]), .outR(w_relay1_delay), .rst(rst));

relay relay1(
	.inR        ( w_relay1_delay    ),
	.inA        ( w_outARelay_4[1]  ),
	.outR       ( w_outRRelay_4[2]  ),
	.outA       ( w_outARelay_4[2]  ),
	.fire       ( o_fire_3[1]       ),
	.rst        ( rst               )
);

wire w_relay2_delay;
delay3U relay2Delay (.inR(w_outRRelay_4[2]), .outR(w_relay2_delay), .rst(rst));

relay relay2(
	.inR        ( w_relay2_delay    ),
	.inA        ( w_outARelay_4[2]  ),
	.outR       ( w_outRRelay_4[3]  ),
	.outA       ( w_outARelay_4[3]  ),
	.fire       ( o_fire_3[2]       ),
	.rst        ( rst               )
);

receiver receiver(
	.inR        ( w_outRRelay_4[3]  ),
	.inA        ( w_outARelay_4[3]  ),
	.i_freeNext ( i_freeNext        ),
	.rst        ( rst               )
);

// make sure regs assignment is before o_driveNext.
delay1U outdelay0 (.inR(o_fire_3[2]), .outR(w_driveNext), .rst(rst));
delay1U outdelay1 (.inR(w_driveNext), .outR(o_driveNext), .rst(rst));
endmodule

