//======================================================
// Project:        RCA
// Module:         NatSplit_2_d
// Author:         YiHua Lu
// Date:           2025/06/18
// Description:    无条件分支;带数据版;对数据不做持久化处理
//                 测试值：1ns给出去
//======================================================
//! 收到i_free再发o_free

`timescale 1ns / 1ps

module cNatSplit2_d_mem#(
    parameter DATA_WIDTH = 10
)(
    (* dont_touch="true" *)input                   i_drive,
    (* dont_touch="true" *)input                   i_freeNext0,i_freeNext1,
    (* dont_touch="true" *)input  [DATA_WIDTH-1:0] i_data,
    (* dont_touch="true" *)output                  o_free,
    (* dont_touch="true" *)output                  o_driveNext0,o_driveNext1,
    (* dont_touch="true" *)output [DATA_WIDTH-1:0] o_data0,
    (* dont_touch="true" *)output [DATA_WIDTH-1:0] o_data1,
    (* dont_touch="true" *)input                   rst
);

 (* dont_touch="true" *)wire w_sendFree;
 (* dont_touch="true" *)wire w_d_sendFree;
 (* dont_touch="true" *)wire w_firstReq;
 (* dont_touch="true" *)wire w_secondReq;
 (* dont_touch="true" *)wire w_dirveReq;
 (* dont_touch="true" *)wire w_andReq;
 (* dont_touch="true" *)wire w_d_andReq;
 
 assign o_data0 = i_data;
 assign o_data1 = i_data;
 
 assign w_andReq   = w_firstReq & w_secondReq;
 assign w_sendFree = w_dirveReq & w_andReq;

 delay2U delay_dandreq (.inR(w_andReq),     .outR(w_d_andReq),   .rst(rst));
 delay1U delay_sendFree(.inR(w_sendFree),   .outR(w_d_sendFree), .rst(rst));
 delay1U delayDSendfree(.inR(w_d_sendFree), .outR(o_free),       .rst(rst));

 contTap driveTap(
   .trig((i_drive&(~w_dirveReq)) | w_d_andReq&w_dirveReq        ),
   .req (w_dirveReq                                             ),
   .rst (rst                                                    ) 
 ); 
 
 contTap firstTap(
 .trig  ((i_freeNext0&(~w_firstReq)) | w_d_sendFree&w_firstReq  ),
 .req   (w_firstReq                                             ),
 .rst   (rst                                                    )
 );
 
 contTap secondTap(
 .trig  ((i_freeNext1&(~w_secondReq)) | w_d_sendFree&w_secondReq),
 .req   (w_secondReq                                            ),
 .rst   (rst                                                    )
 );

 assign o_driveNext0 = i_drive;
 assign o_driveNext1 = i_drive;

endmodule

