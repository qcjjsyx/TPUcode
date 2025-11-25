//-----------------------------------------------
//	module name: clickfifo1
//	author: Tong Fu, Lingzhuang Zhang
//	version: 1st version (2022-11-15)
//-----------------------------------------------

`timescale 1ns / 1ps

module cFifo2_mem(
    // last -->
    (* dont_touch="true" *)input           i_drive,
    (* dont_touch="true" *)output          o_free,
    // --> next
    (* dont_touch="true" *)output          o_driveNext,
    (* dont_touch="true" *)input           i_freeNext,
    (* dont_touch="true" *)output  [1:0]   o_fire_2,
    // reset signal
    (* dont_touch="true" *)input           rst
);

wire [2:0]  w_outRRelay_3,w_outARelay_3;
wire        w_driveNext;

// pipeline
sender sender(
	.i_drive    ( i_drive           ),
	.o_free     ( o_free            ),
	.outR       ( w_outRRelay_3[0]  ),
	.i_free     ( w_driveNext       ),
	.rst        ( rst               )
);

wire w_relay0_delay;
delay3U relay0Delay (.inR(w_outRRelay_3[0]), .outR(w_relay0_delay), .rst(rst));

relay relay0(
	.inR        ( w_relay0_delay    ),
	.inA        ( w_outARelay_3[0]  ),
	.outR       ( w_outRRelay_3[1]  ),
	.outA       ( w_outARelay_3[1]  ),
	.fire       ( o_fire_2[0]       ),
	.rst        ( rst               )
);

wire w_relay1_delay;
delay3U relay1Delay (.inR(w_outRRelay_3[1]), .outR(w_relay1_delay), .rst(rst));

relay relay1(
	.inR        ( w_relay1_delay    ),
	.inA        ( w_outARelay_3[1]  ),
	.outR       ( w_outRRelay_3[2]  ),
	.outA       ( w_outARelay_3[2]  ),
	.fire       ( o_fire_2[1]       ),
	.rst        ( rst               )
);

receiver receiver(
	.inR        ( w_outRRelay_3[2]  ),
	.inA        ( w_outARelay_3[2]  ),
	.i_freeNext ( i_freeNext        ),
	.rst        ( rst               )
);


delay1U outdelay0 (.inR(o_fire_2[1]), .outR(w_driveNext), .rst(rst));
delay1U outdelay1 (.inR(w_driveNext), .outR(o_driveNext), .rst(rst));
endmodule

