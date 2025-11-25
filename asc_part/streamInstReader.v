module streamInstReader(


    // control Signals 
    //0
    input i_driveRead_0,
    output o_freeRead_0,
    input[31:0] i_readAddr_0,
    output o_driveRead_0,
    input i_freeRead_0,
    output[127:0] o_readData_0,

     //1
    input i_driveRead_1,
    output o_freeRead_1,
    input[31:0] i_readAddr_1,
    output o_driveRead_1,
    input i_freeRead_1,
    output[127:0] o_readData_1,

    //2
    input i_driveRead_2,
    output o_freeRead_2,
    input[31:0] i_readAddr_2,
    output o_driveRead_2,
    input i_freeRead_2,
    output[127:0] o_readData_2,

    //3
    input i_driveRead_3,
    output o_freeRead_3,
    input[31:0] i_readAddr_3,
    output o_driveRead_3,
    input i_freeRead_3,
    output[127:0] o_readData_3,


    //4
    input i_driveRead_4,
    output o_freeRead_4,
    input[31:0] i_readAddr_4,
    output o_driveRead_4,
    input i_freeRead_4,
    output[127:0] o_readData_4,


    //5
    input i_driveRead_5,
    output o_freeRead_5,
    input[31:0] i_readAddr_5,
    output o_driveRead_5,
    input i_freeRead_5,
    output[127:0] o_readData_5,


    //6
    input i_driveRead_6,
    output o_freeRead_6,
    input[31:0] i_readAddr_6,
    output o_driveRead_6,
    input i_freeRead_6,
    output[127:0] o_readData_6,


    //7
    input i_driveRead_7,
    output o_freeRead_7,
    input[31:0] i_readAddr_7,
    output o_driveRead_7,
    input i_freeRead_7,
    output[127:0] o_readData_7,



    //8
    input i_driveRead_8,
    output o_freeRead_8,
    input[31:0] i_readAddr_8,
    output o_driveRead_8,
    input i_freeRead_8,
    output[127:0] o_readData_8,




    // BRAM READ Interface
    output RD_START,
    output[31:0] RD_ADDR,
    input[127:0] RD_DATA,
    input RD_DONE,


    input rst

);

reg [3:0] who_read;
always @(*) begin
    if (!rst) begin
        who_read <= 4'd0;
    end else begin
    if (i_driveRead_0) begin
        who_read <= 4'd0;
    end else if (i_driveRead_1) begin
        who_read <= 4'd1;
    end else if (i_driveRead_2) begin
        who_read <= 4'd2;
    end else if (i_driveRead_3) begin
        who_read <= 4'd3;
    end else if (i_driveRead_4) begin
        who_read <= 4'd4;
    end else if (i_driveRead_5) begin
        who_read <= 4'd5;
    end else if (i_driveRead_6) begin
        who_read <= 4'd6;
    end else if (i_driveRead_7) begin
        who_read <= 4'd7;
    end else if (i_driveRead_8) begin
        who_read <= 4'd8;
    end else begin
        who_read <= who_read;
    end
    end
end


cMutexMerge9_d_streamInst#(
    .DATA_WIDTH   ( 32 )
)u_cMutexMerge9_d_streamInst(
    .i_drive0     ( i_driveRead_0 ),   
    .o_free0      ( o_freeRead_0  ),    
    .i_data0      ( i_readAddr_0  ),
    .i_drive1     ( i_driveRead_1 ),    
    .o_free1      ( o_freeRead_1  ),
    .i_data1      ( i_readAddr_1  ),
    .i_drive2     ( i_driveRead_2  ),
    .o_free2      ( o_freeRead_2  ),
    .i_data2      ( i_readAddr_2  ),
    .i_drive3     ( i_driveRead_3     ),
    .o_free3      ( o_freeRead_3      ),
    .i_data3      ( i_readAddr_3      ),
    .i_drive4     ( i_driveRead_4     ),
    .o_free4      ( o_freeRead_4      ),
    .i_data4      ( i_readAddr_4      ),
    .i_drive5     ( i_driveRead_5     ),
    .o_free5      ( o_freeRead_5      ),
    .i_data5      ( i_readAddr_5      ),
    .i_drive6     ( i_driveRead_6     ),
    .o_free6      ( o_freeRead_6      ),
    .i_data6      ( i_readAddr_6      ),
    .i_drive7     ( i_driveRead_7     ),
    .o_free7      ( o_freeRead_7      ),
    .i_data7      ( i_readAddr_7      ),
    .i_drive8     ( i_driveRead_8     ),
    .o_free8      ( o_freeRead_8      ),
    .i_data8      ( i_readAddr_8      ),
    .o_driveNext  ( w_driveRead     ),
    .i_freeNext   ( w_freeRead   ),
    .o_data       ( RD_ADDR      ), 
    .rst          ( rst          )
);
wire w_driveRead;
wire w_freeRead;
wire w_fireRead, w_fireReaddelay;

cFifo1_user u_cFifo1_user_0(
    .i_drive     ( w_driveRead     ),
    .o_free      ( w_freeRead      ),
    .o_driveNext ( RD_START ),
    .i_freeNext  ( w_fireReaddelay  ),
    .o_fire      ( w_fireRead      ),
    .rst         ( rst         )
);
delay1U u_delay1U(
    .inR  ( w_fireRead  ),
    .outR ( w_fireReaddelay ),
    .rst  ( rst  )
);


wire w_driveReadDone;
wire w_freeReadDone;
wire w_fireReadDone;
reg [127:0] read_data_reg;
cFifo1_user u_cFifo1_user_0(
    .i_drive     ( RD_DONE     ),
    .o_free      (       ),
    .o_driveNext ( w_driveReadDone ),
    .i_freeNext  ( w_freeReadDone  ),
    .o_fire      ( w_fireReadDone      ),
    .rst         ( rst         )
);
always @(posedge w_fireReadDone or negedge rst) begin
    if (!rst) begin
        read_data_reg <= 128'b0;
    end else begin
        read_data_reg <= RD_DATA;
    end
end

wire vilid0,valid1,valid2,valid3,valid4,valid5,valid6,valid7,valid8;
assign valid0 = (who_read == 4'd0);
assign valid1 = (who_read == 4'd1);
assign valid2 = (who_read == 4'd2);
assign valid3 = (who_read == 4'd3);
assign valid4 = (who_read == 4'd4);
assign valid5 = (who_read == 4'd5);
assign valid6 = (who_read == 4'd6);
assign valid7 = (who_read == 4'd7);
assign valid8 = (who_read == 4'd8);

cSelSplit9_streamInst u_cSelSplit9_streamInst(
    .i_drive      ( w_driveReadDone      ),
    .i_freeNext0  ( i_freeRead_0  ),
    .i_freeNext1  ( i_freeRead_1  ),
    .i_freeNext2  ( i_freeRead_2  ),
    .i_freeNext3  ( i_freeRead_3  ),
    .i_freeNext4  ( i_freeRead_4  ),
    .i_freeNext5  ( i_freeRead_5  ),
    .i_freeNext6  ( i_freeRead_6  ),
    .i_freeNext7  ( i_freeRead_7  ),
    .i_freeNext8  ( i_freeRead_8  ),
    .valid0       ( valid0       ),
    .valid1       ( valid1       ),
    .valid2       ( valid2       ),
    .valid3       ( valid3       ),
    .valid4       ( valid4       ),
    .valid5       ( valid5       ),
    .valid6       ( valid6       ),
    .valid7       ( valid7       ),
    .valid8       ( valid8       ),
    .o_free       ( w_freeReadDone       ),
    .o_driveNext0 ( o_driveRead_0 ),
    .o_driveNext1 ( o_driveRead_1 ),
    .o_driveNext2 ( o_driveRead_2 ),
    .o_driveNext3 ( o_driveRead_3 ),
    .o_driveNext4 ( o_driveRead_4 ),
    .o_driveNext5 ( o_driveRead_5 ),
    .o_driveNext6 ( o_driveRead_6 ),
    .o_driveNext7 ( o_driveRead_7 ),
    .o_driveNext8 ( o_driveRead_8 ),
    .rst          ( rst          )
);




assign o_readData_0 = read_data_reg;
assign o_readData_1 = read_data_reg;
assign o_readData_2 = read_data_reg;
assign o_readData_3 = read_data_reg;
assign o_readData_4 = read_data_reg;
assign o_readData_5 = read_data_reg;
assign o_readData_6 = read_data_reg;
assign o_readData_7 = read_data_reg;
assign o_readData_8 = read_data_reg;
    

endmodule