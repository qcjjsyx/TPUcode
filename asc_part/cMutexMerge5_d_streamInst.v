//===============================================================================
// Project:        RCA
// Module:         ConfMerge_2_d
// Author:         YiHua Lu
// Date:           2025/06/18
// Description:    互斥融合;带数据版;对数据不做持久化保存；
//                 在控制链加入数据的模型中，mutex的实现逻辑是导致数据非持久化的原因
//                 测试值：1ns左右可出去
//===============================================================================
//! 收到i_free后再发o_free

`timescale 1ns / 1ps

module cMutexMerge5_d_streamInst#(
    parameter DATA_WIDTH = 128
)(
    // in0 -->
    (* dont_touch="true" *)input                    i_drive0    ,
    (* dont_touch="true" *)output                   o_free0     , 
    (* dont_touch="true" *)input  [DATA_WIDTH-1:0]  i_data0,
    // in1 -->
    (* dont_touch="true" *)input                    i_drive1    ,
    (* dont_touch="true" *)output                   o_free1     ,
    (* dont_touch="true" *)input  [DATA_WIDTH-1:0]  i_data1,
    // in2 -->
    (* dont_touch="true" *)input                    i_drive2    ,
    (* dont_touch="true" *)output                   o_free2     ,
    (* dont_touch="true" *)input  [DATA_WIDTH-1:0]  i_data2,
    // in3 -->
    (* dont_touch="true" *)input                    i_drive3    ,
    (* dont_touch="true" *)output                   o_free3     ,
    (* dont_touch="true" *)input  [DATA_WIDTH-1:0]  i_data3,
    // in4 -->
    (* dont_touch="true" *)input                    i_drive4    ,
    (* dont_touch="true" *)output                   o_free4     ,
    (* dont_touch="true" *)input  [DATA_WIDTH-1:0]  i_data4,
    // in5 -->
    // (* dont_touch="true" *)input                    i_drive5    ,
    // (* dont_touch="true" *)output                   o_free5     ,
    // (* dont_touch="true" *)input  [DATA_WIDTH-1:0]  i_data5,
    // // in6 -->
    // (* dont_touch="true" *)input                    i_drive6    ,
    // (* dont_touch="true" *)output                   o_free6     ,
    // (* dont_touch="true" *)input  [DATA_WIDTH-1:0]  i_data6,
    // // in7 -->
    // (* dont_touch="true" *)input                    i_drive7    ,
    // (* dont_touch="true" *)output                   o_free7     ,
    // (* dont_touch="true" *)input  [DATA_WIDTH-1:0]  i_data7,
    // // in8 -->
    // (* dont_touch="true" *)input                    i_drive8    ,
    // (* dont_touch="true" *)output                   o_free8     ,
    // (* dont_touch="true" *)input  [DATA_WIDTH-1:0]  i_data8,




    // --> out
    (* dont_touch="true" *)output                   o_driveNext ,
    (* dont_touch="true" *)input                    i_freeNext  ,
    (* dont_touch="true" *)output [DATA_WIDTH-1:0]  o_data,

    (* dont_touch="true" *)input                    rst
);

(* dont_touch="true" *)wire        w_firstTrig     , w_secondTrig, w_thirdTrig,
                                w_fourthTrig    , w_fifthTrig;
                                // w_sixthTrig     , w_seventhTrig,
                                // w_eighthTrig    , w_ninthTrig;
(* dont_touch="true" *)wire        w_firstReq      , w_secondReq, w_thirdReq,
                                w_fourthReq     , w_fifthReq;
                                // w_sixthReq      , w_seventhReq,
                                // w_eighthReq     , w_ninthReq;

(* dont_touch="true" *)wire        w_free0         , w_free1, w_free2,
                                w_free3         , w_free4;
                                // w_free5         , w_free6,
                                // w_free7         , w_free8;
(* dont_touch="true" *)wire        w_free0_delay   , w_free1_delay,w_free2_delay,
                                w_free3_delay   , w_free4_delay;
                                // w_free5_delay   , w_free6_delay,
                                // w_free7_delay   , w_free8_delay;


(* dont_touch="true" *)wire [DATA_WIDTH-1:0] w_data;

delay1U delay0(.inR(w_free0), .outR(w_free0_delay), .rst(rst));
assign w_firstTrig = i_drive0&(~w_firstReq) | w_free0_delay&(w_firstReq);

contTap firstTap(
    .trig       ( w_firstTrig   ),
    .req        ( w_firstReq    ),
    .rst        ( rst           )
);

delay1U delay1(.inR(w_free1), .outR(w_free1_delay), .rst(rst));
assign w_secondTrig = i_drive1&(~w_secondReq) | w_free1_delay&(w_secondReq);

contTap secondTap(
    .trig       ( w_secondTrig  ),
    .req        ( w_secondReq   ),
    .rst        ( rst           )
);

delay1U delay2(.inR(w_free2), .outR(w_free2_delay), .rst(rst));
assign w_thirdTrig = i_drive2&(~w_thirdReq) | w_free2_delay&(w_thirdReq);
contTap thirdTap(
    .trig       ( w_thirdTrig   ),
    .req        ( w_thirdReq    ),
    .rst        ( rst           )
);

delay1U delay3(.inR(w_free3), .outR(w_free3_delay), .rst(rst));
assign w_fourthTrig = i_drive3&(~w_fourthReq) | w_free3_delay&(w_fourthReq);
contTap fourthTap(  
    .trig       ( w_fourthTrig  ),
    .req        ( w_fourthReq   ),
    .rst        ( rst           )
); 

delay1U delay4(.inR(w_free4), .outR(w_free4_delay), .rst(rst));
assign w_fifthTrig = i_drive4&(~w_fifthReq) | w_free4_delay&(w_fifthReq);
contTap fifthTap(  
    .trig       ( w_fifthTrig   ),
    .req        ( w_fifthReq    ),
    .rst        ( rst           )
);      

// delay1U delay5(.inR(w_free5), .outR(w_free5_delay), .rst(rst));
// assign w_sixthTrig = i_drive5&(~w_sixthReq) | w_free5_delay&(w_sixthReq);
// contTap sixthTap(  
//     .trig       ( w_sixthTrig   ),
//     .req        ( w_sixthReq    ),
//     .rst        ( rst           )
// );      

// delay1U delay6(.inR(w_free6), .outR(w_free6_delay), .rst(rst));
// assign w_seventhTrig = i_drive6&(~w_seventhReq) | w_free6_delay&(w_seventhReq);
// contTap seventhTap( 
//     .trig       ( w_seventhTrig ),
//     .req        ( w_seventhReq  ),
//     .rst        ( rst           )
// );      


// delay1U delay7(.inR(w_free7), .outR(w_free7_delay), .rst(rst));
// assign w_eighthTrig = i_drive7&(~w_eighthReq) | w_free7_delay&(w_eighthReq);
// contTap eighthTap(  
//     .trig       ( w_eighthTrig  ),
//     .req        ( w_eighthReq   ),
//     .rst        ( rst           )
// );

// delay1U delay8(.inR(w_free8), .outR(w_free8_delay), .rst(rst));
// assign w_ninthTrig = i_drive8&(~w_ninthReq) | w_free8_delay&(w_ninthReq);
// contTap ninthTap(  
//     .trig       ( w_ninthTrig   ),
//     .req        ( w_ninthReq    ),
//     .rst        ( rst           )
// );





// 数据需要一定的时间被赋值，这里让o_drive出去前数据已经准备好
(* dont_touch="true" *)wire w_driveNext = i_drive0 | i_drive1 | i_drive2 | i_drive3 | i_drive4;
                                // | i_drive5 | i_drive6 | i_drive7 | i_drive8;
delay1U delay_out(.inR(w_driveNext), .outR(o_driveNext), .rst(rst));

assign w_free0 = i_freeNext & w_firstReq;
assign w_free1 = i_freeNext & w_secondReq;
assign w_free2 = i_freeNext & w_thirdReq;
assign w_free3 = i_freeNext & w_fourthReq;
assign w_free4 = i_freeNext & w_fifthReq;
// assign w_free5 = i_freeNext & w_sixthReq;
// assign w_free6 = i_freeNext & w_seventhReq;
// assign w_free7 = i_freeNext & w_eighthReq;
// assign w_free8 = i_freeNext & w_ninthReq;

assign o_free0 = w_free0;
assign o_free1 = w_free1;
assign o_free2 = w_free2;
assign o_free3 = w_free3;
assign o_free4 = w_free4;
// assign o_free5 = w_free5;
// assign o_free6 = w_free6;
// assign o_free7 = w_free7;
// assign o_free8 = w_free8;


assign w_data =  (i_drive0) ? i_data0 :
                 (i_drive1) ? i_data1 :
                 (i_drive2) ? i_data2 :
                 (i_drive3) ? i_data3 :
                 (i_drive4) ? i_data4 :
                //  (i_drive5) ? i_data5 :
                //  (i_drive6) ? i_data6 :
                //  (i_drive7) ? i_data7 :
                //  (i_drive8) ? i_data8 :
                              {DATA_WIDTH{1'b0}} ;
assign o_data = w_data;

endmodule
