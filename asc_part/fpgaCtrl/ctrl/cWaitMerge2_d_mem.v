//===============================================================================
// Project:        RCA
// Module:         WaitMerge_2_d
// Author:         YiHua Lu
// Date:           2025/06/18
// Description:    二路融合;带数据版;不对数据做持久化
//                 测试值：1ns给出去
//===============================================================================
//! 收到i_free后向前发送o_free

`timescale 1ns / 1ps

module cWaitMerge2_d_mem#(
    parameter DATA_WIDTH=32
)(    // in0 -->
    (* dont_touch="true" *)input                   i_drive0    ,
    (* dont_touch="true" *)output                  o_free0     , 
    (* dont_touch="true" *)input[DATA_WIDTH-1:0]   i_data0     ,
    // in1 -->
    (* dont_touch="true" *)input                   i_drive1    ,
    (* dont_touch="true" *)output                  o_free1     ,
    (* dont_touch="true" *)input[DATA_WIDTH-1:0]   i_data1     ,
    // --> out
    (* dont_touch="true" *)output                  o_driveNext ,
    (* dont_touch="true" *)input                   i_freeNext  ,
    (* dont_touch="true" *)output[2*DATA_WIDTH-1:0]o_data      ,
    (* dont_touch="true" *)input                   rst
);

(* dont_touch="true" *)wire        w_firstTrig, w_secondTrig;
(* dont_touch="true" *)wire        w_firstReq , w_secondReq;
(* dont_touch="true" *)wire        w_free0    , w_free1;
(* dont_touch="true" *)wire        w_drive0   , w_drive1;
(* dont_touch="true" *)wire        w_d_andReq;
(* dont_touch="true" *)wire        w_allReqCome, w_outARelay, w_outRRelay, w_driveNext;

assign w_firstTrig = i_drive0 | i_freeNext;
contTap firstTap(
    .trig       ( w_firstTrig   ),
    .req        ( w_firstReq    ),
    .rst        ( rst           )
);

assign w_secondTrig = i_drive1 | i_freeNext;
contTap secondTap(
    .trig       ( w_secondTrig  ),
    .req        ( w_secondReq   ),
    .rst        ( rst           )
);

assign w_allReqCome = w_firstReq & w_secondReq;

// 控制两个都到后通过延迟的方式产生o_drive
delay4U u_delay(
    .inR  ( w_allReqCome ),
    .rst  ( rst          ),
    .outR ( w_d_andReq   )
);

assign o_driveNext = w_allReqCome ^ w_d_andReq & w_secondReq & w_firstReq;


assign o_data = {i_data1,i_data0};
assign o_free0 = i_freeNext;
assign o_free1 = i_freeNext;

endmodule
