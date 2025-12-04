//-----------------------------------------------
//	module name: relay
//	author: Tong Fu, Lingzhuang Zhang
//  decription: 
//      the width of pulse is 0.745ns now with one LUT1 delay.
//	version: 1st version (2023-06-15)
//-----------------------------------------------
`timescale 1ns / 1ps

(* dont_touch="true" *) module relay(
    input           inR     , 
    output          inA     , 
    output          outR    , 
    input           outA    , 
    output          fire    , 
    input           rst
); 

// wire type
wire            inAR, outAR, notR0;
wire    [1:0]   R0_del;
// reg type
reg     R0;

(* dont_touch="true" *)LUT2 #(.INIT(4'b0110)) neqIn (
   .O   ( inAR          ),  
   .I0  ( inR           ), 
   .I1  ( inA           )  
);

(* dont_touch="true" *)LUT2 #(.INIT(4'b1001)) eqOut (
   .O   ( outAR         ),  
   .I0  ( outA          ), 
   .I1  ( outR          )  
);

//(* dont_touch="true" *)LUT2 #(.INIT(4'b1000)) andFire (
//   .O   ( fire          ),   
//   .I0  ( inAR          ), 
//   .I1  ( outAR         ) 
//);
assign fire = inAR & outAR;

always@(posedge fire or negedge rst) begin
    if(!rst)
        R0 <= 1'b0;
    else
        R0 <= notR0;
end

(* dont_touch="true" *)LUT1 #(.INIT(2'b01)) tmp_inv (
   .O   ( notR0         ),   
   .I0  ( R0            )  
);


(* dont_touch="true" *) LUT1 #(.INIT(2'b10)) R0_delay0 ( 
   .O   ( R0_del[0]     ),   
   .I0  ( R0            )  	
);

(* dont_touch="true" *) LUT1 #(.INIT(2'b10)) R0_delay1 ( 
   .O   ( R0_del[1]     ),   
   .I0  ( R0_del[0]     )  	
);

assign outR = R0_del[0];
assign inA  = R0_del[1];


endmodule