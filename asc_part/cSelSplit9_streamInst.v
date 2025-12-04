
`timescale 1ns / 1ps

module cSelSplit9_streamInst
    (
    (* dont_touch="true" *)input  i_drive,
    (* dont_touch="true" *)input  i_freeNext0,i_freeNext1,i_freeNext2,i_freeNext3,i_freeNext4,
    (* dont_touch="true" *)input  i_freeNext5,i_freeNext6,i_freeNext7,i_freeNext8,

    (* dont_touch="true" *)input  valid0,
    (* dont_touch="true" *)input  valid1,
    (* dont_touch="true" *)input  valid2,
    (* dont_touch="true" *)input  valid3,
    (* dont_touch="true" *)input  valid4,
    (* dont_touch="true" *)input  valid5,
    (* dont_touch="true" *)input  valid6,
    (* dont_touch="true" *)input  valid7,
    (* dont_touch="true" *)input  valid8,

    (* dont_touch="true" *)output o_free,
    (* dont_touch="true" *)output o_driveNext0,o_driveNext1,o_driveNext2,o_driveNext3,o_driveNext4,
    (* dont_touch="true" *)output o_driveNext5,o_driveNext6,o_driveNext7,o_driveNext8,

    (* dont_touch="true" *)input  rst
);

(* dont_touch="true" *)wire w_sendFree;
(* dont_touch="true" *)wire w_d_sendFree;
(* dont_touch="true" *)wire w_firstReq;
(* dont_touch="true" *)wire w_secondReq;
(* dont_touch="true" *)wire w_thirdReq;
(* dont_touch="true" *)wire w_fourthReq;
(* dont_touch="true" *)wire w_fifthReq;
(* dont_touch="true" *)wire w_sixthReq;
(* dont_touch="true" *)wire w_seventhReq;
(* dont_touch="true" *)wire w_eighthReq;
(* dont_touch="true" *)wire w_ninthReq;
(* dont_touch="true" *)wire w_dirveReq;
(* dont_touch="true" *)wire w_andReq;
(* dont_touch="true" *)wire w_d_andReq;

assign w_andReq = (w_firstReq&valid0) | (w_secondReq&valid1) | (w_thirdReq&valid2) | (w_fourthReq&valid3) | (w_fifthReq&valid4)
                | (w_sixthReq&valid5) | (w_seventhReq&valid6) | (w_eighthReq&valid7) | (w_ninthReq&valid8);
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

conTap thirdTap(
    .trig((i_freeNext2&(~w_thirdReq)) | w_d_sendFree&w_thirdReq),
    .req(w_thirdReq),
    .rst(rst)
);

contTap fourthTap(
    .trig((i_freeNext3&(~w_fourthReq)) | w_d_sendFree&w_fourthReq),
    .req(w_fourthReq),
    .rst(rst)
);

contTap fifthTap(
    .trig((i_freeNext4&(~w_fifthReq)) | w_d_sendFree&w_fifthReq),
    .req(w_fifthReq),
    .rst(rst)
);

contTap sixthTap(
    .trig((i_freeNext5&(~w_sixthReq)) | w_d_sendFree&w_sixthReq),
    .req(w_sixthReq),
    .rst(rst)
);


contTap seventhTap(
    .trig((i_freeNext6&(~w_seventhReq)) | w_d_sendFree&w_seventhReq),
    .req(w_seventhReq),
    .rst(rst)
);



contTap eighthTap(
    .trig((i_freeNext7&(~w_eighthReq)) | w_d_sendFree&w_eighthReq),
    .req(w_eighthReq),
    .rst(rst)
);



contTap ninthTap(
    .trig((i_freeNext8&(~w_ninthReq)) | w_d_sendFree&w_ninthReq),
    .req(w_ninthReq),
    .rst(rst)
);



assign o_driveNext0 = i_drive & valid0;
assign o_driveNext1 = i_drive & valid1;
assign o_driveNext2 = i_drive & valid2;
assign o_driveNext3 = i_drive & valid3;
assign o_driveNext4 = i_drive & valid4;
assign o_driveNext5 = i_drive & valid5;
assign o_driveNext6 = i_drive & valid6;
assign o_driveNext7 = i_drive & valid7;
assign o_driveNext8 = i_drive & valid8;


endmodule
