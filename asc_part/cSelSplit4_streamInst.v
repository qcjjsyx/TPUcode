`timescale 1ns / 1ps

module cSelSplit4_streamInst
    (
    (* dont_touch="true" *)input  i_drive,
    (* dont_touch="true" *)input  i_freeNext0,i_freeNext1,i_freeNext2,i_freeNext3,

    (* dont_touch="true" *)input  valid0,
    (* dont_touch="true" *)input  valid1,
    (* dont_touch="true" *)input  valid2,
    (* dont_touch="true" *)input  valid3,

    (* dont_touch="true" *)output o_free,
    (* dont_touch="true" *)output o_driveNext0,o_driveNext1,o_driveNext2,o_driveNext3,

    (* dont_touch="true" *)input  rst
);

(* dont_touch="true" *)wire w_sendFree;
(* dont_touch="true" *)wire w_d_sendFree;
(* dont_touch="true" *)wire w_firstReq;
(* dont_touch="true" *)wire w_secondReq;
(* dont_touch="true" *)wire w_thirdReq;
(* dont_touch="true" *)wire w_fourthReq;
(* dont_touch="true" *)wire w_dirveReq;
(* dont_touch="true" *)wire w_andReq;
(* dont_touch="true" *)wire w_d_andReq;

assign w_andReq = (w_firstReq&valid0) | (w_secondReq&valid1);
assign w_sendFree = w_dirveReq & w_andReq;

delay2U delay_dandreq (.inR(w_andReq), .outR(w_d_andReq), .rst(rst));
delay1U delay_sendFree (.inR(w_sendFree), .outR(w_d_sendFree), .rst(rst));
delay1U delayDSendfree (.inR(w_d_sendFree), .outR(o_free), .rst(rst));

contTap driveTap(
    .trig((i_drive&(~w_dirveReq)) | w_d_andReq&w_dirveReq),
    .req(w_dirveReq),
    .rst(rst)
); 

contTap firstTap(
    .trig((i_freeNext0&(~w_firstReq)) | w_d_sendFree&w_firstReq),
    .req(w_firstReq),
    .rst(rst)
);

contTap secondTap(
    .trig((i_freeNext1&(~w_secondReq)) | w_d_sendFree&w_secondReq),
    .req(w_secondReq),
    .rst(rst)
);

contTap thirdTap(
    .trig((i_freeNext2&(~w_thirdReq)) | w_d_sendFree&w_thirdReq),
    .req(w_thirdReq),
    .rst(rst)
);
contTap fourthTap(
    .trig((i_freeNext3&(~w_fourthReq)) | w_d_sendFree&w_fourthReq),
    .req(w_fourthReq),
    .rst(rst)
);

assign o_driveNext0 = i_drive & valid0;
assign o_driveNext1 = i_drive & valid1;
assign o_driveNext2 = i_drive & valid2;
assign o_driveNext3 = i_drive & valid3;

endmodule
