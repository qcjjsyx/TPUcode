//-----------------------------------------------
//	module name: pmtRelay
//	author: Tong Fu, Lingzhuang Zhang
//	version: 1st version (2023-06-15)
//-----------------------------------------------
`timescale 1ns / 1ps

(* dont_touch="true" *) module pmtRelay(
    input           inR     , 
    output          inA     , 
    output          outR    , 
    input           outA    ,
    input           pmt     ,
    output          fire    , 
    input           rst
); 

// wire type
wire            inAR, outAR, notR0, fire0;
wire    [1:0]   R0_del;
// reg type
reg     R0;

LUT2 #(.INIT(4'b0110)) neqIn (
   .O   ( inAR          ),  
   .I0  ( inR           ), 
   .I1  ( inA           )  
);

LUT2 #(.INIT(4'b1001)) eqOut (
   .O   ( outAR         ),  
   .I0  ( outA          ), 
   .I1  ( outR          )  
);

LUT2 #(.INIT(4'b1000)) andFire (
   .O   ( fire0         ),   
   .I0  ( inAR          ), 
   .I1  ( outAR         ) 
);

LUT2 #(.INIT(4'b1000)) fire_pmt (
   .O   ( fire          ),   
   .I0  ( fire0         ), 
   .I1  ( pmt           ) 
);

always@(posedge fire or negedge rst) begin
    if(!rst)
        R0 <= 1'b0;
    else
        R0 <= notR0;
end

LUT1 #(.INIT(2'b01)) tmp_inv (
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