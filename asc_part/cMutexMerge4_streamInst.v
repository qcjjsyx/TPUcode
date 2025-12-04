//===============================================================================
// Project:        RCA
// Module:         ConfMerge_2
// Author:         YiHua Lu
// Date:           2025/06/18
// Description:    二路互斥融合; 不带数据版
//===============================================================================
//! 收到i_free后再发o_free

`timescale 1ns / 1ps

module cMutexMerge4_streamInst(
    // in0 -->
    (* dont_touch="true" *)input       i_drive0    ,
    (* dont_touch="true" *)output      o_free0     , 
    // in1 -->
    (* dont_touch="true" *)input       i_drive1    ,
    (* dont_touch="true" *)output      o_free1     ,
    // in2 -->
    (* dont_touch="true" *)input       i_drive2    ,
    (* dont_touch="true" *)output      o_free2     ,
    // in3 -->
    (* dont_touch="true" *)input       i_drive3    ,
    (* dont_touch="true" *)output      o_free3     ,


    // --> out
    (* dont_touch="true" *)output      o_driveNext ,
    (* dont_touch="true" *)input       i_freeNext  ,
    (* dont_touch="true" *)input       rst
);

(* dont_touch="true" *)wire        w_firstTrig, w_secondTrig,w_thirdTrig, w_fourthTrig;
(* dont_touch="true" *)wire        w_firstReq,  w_secondReq, w_thirdReq,  w_fourthReq;
(* dont_touch="true" *)wire        w_freeNext;
(* dont_touch="true" *)wire        w_free0, w_free1,w_free2,w_free3;
assign w_firstTrig = i_drive0&(~w_firstReq) | w_freeNext&(w_firstReq);
contTap firstTap(
    .trig       ( w_firstTrig   ),
    .req        ( w_firstReq    ),
    .rst        ( rst           )
);

assign w_secondTrig = i_drive1&(~w_secondReq) | w_freeNext&(w_secondReq);
contTap secondTap(
    .trig       ( w_secondTrig  ),
    .req        ( w_secondReq   ),
    .rst        ( rst           )
);

assign w_thirdTrig = i_drive2&(~w_thirdReq) | w_freeNext&(w_thirdReq);
contTap thirdTap(
    .trig       ( w_thirdTrig   ),
    .req        ( w_thirdReq    ),
    .rst        ( rst           )
);

assign w_fourthTrig = i_drive3&(~w_fourthReq) | w_freeNext&(w_fourthReq);
contTap fourthTap(
    .trig       ( w_fourthTrig  ),  
    .req        ( w_fourthReq   ),
    .rst        ( rst           )
);

// assign w_fifthTrig = i_drive4&(~w_fifthReq) | w_freeNext&(w_fifthReq);
// contTap fifthTap(
//     .trig       ( w_fifthTrig   ),
//     .req        ( w_fifthReq    ),
//     .rst        ( rst           )
// );


assign o_driveNext = i_drive0 | i_drive1 | i_drive2 | i_drive3;

assign w_free0 = i_freeNext & w_firstReq;
assign w_free1 = i_freeNext & w_secondReq;
assign w_free2 = i_freeNext & w_thirdReq;
assign w_free3 = i_freeNext & w_fourthReq;
// assign w_free4 = i_freeNext & w_fifthReq;
delay1U delay0 (.inR(i_freeNext), .outR(w_freeNext), .rst(rst));

assign o_free0 = w_free0;
assign o_free1 = w_free1;
assign o_free2 = w_free2;
assign o_free3 = w_free3;
// assign o_free4 = w_free4;


endmodule
