module top_mover(
    // Control Signals
    input MOVE_START,
    input[7:0] MOVE_NUM,
    input[31:0] SOURCE_ADDR,
    input[31:0] DEST_ADDR,
    output MOVE_DONE,

    output RD_START,
    output [31:0] RD_ADDR,
    input[127:0] RD_DATA,
    input RD_DONE,

    output WR_START,
    output [31:0] WR_ADDR,
    output [127:0] WR_DATA,
    input WR_DONE,




    input ACLK,
    input ARESETN
);




mover u_mover(
    .MOVE_START  ( MOVE_START  ),
    .MOVE_NUM    ( MOVE_NUM    ),
    .SOURCE_ADDR ( SOURCE_ADDR ),
    .DEST_ADDR   ( DEST_ADDR   ),
    .MOVE_DONE   ( MOVE_DONE   ),
    .RD_START    ( RD_START    ),
    .RD_ADDR     ( RD_ADDR     ),
    .RD_DATA     ( RD_DATA     ),
    .RD_DONE     ( RD_DONE     ),
    .WR_START    ( WR_START    ),
    .WR_ADDR     ( WR_ADDR     ),
    .WR_DATA     ( WR_DATA     ),
    .WR_DONE     ( WR_DONE     ),
    .ACLK        ( ACLK        ),
    .ARESETN     ( ARESETN     )
);



endmodule