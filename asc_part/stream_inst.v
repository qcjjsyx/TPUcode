module stream_inst(
    // Control Signals
    input CAN_READ_INST,
    output FINISH,

    // mover Interface

    // BRAM READ Interface
    output RD_START,
    output [31:0] RD_ADDR,
    input [127:0] RD_DATA,
    input RD_DONE,


    // TPU Interface
    output o_drive2TPU,
    input  i_freeFTPU,
    output[127:0] o_data2TPU_128,
    output o_finish2TPU,

    input i_driveFTPU,
    output o_free2TPU,
    input[127:0] i_dataFTPU_128,
    input i_finishFTPU,

    input rst

);



wire w_drive_readStreamInst, w_free_readStreamInst;

cFifo1_user read_StreamInst_fifo(
    .i_drive     ( CAN_READ_INST     ),
    .o_free      (       ),
    .o_driveNext ( w_drive_readStreamInst ),
    .i_freeNext  ( w_free_readStreamInst ),
    .o_fire      (     ), 
    .rst         ( rst         )
);









// 锁存指令
wire w_drive_streamInstReadDone;
wire w_free_streamInstReadDone;
wire w_fire_streamInstReadDone;
wire w_drive_analyzeInst;
wire w_free_analyzeInst;
reg [127:0] INST_REG;
reg[7:0] OP_REG;
cFifo1_user read_Inst_fifo(
    .i_drive     ( w_drive_streamInstReadDone ),
    .o_free      ( w_free_streamInstReadDone ),
    .o_driveNext ( w_drive_analyzeInst ),
    .i_freeNext  ( w_free_analyzeInst ),
    .o_fire      ( w_fire_streamInstReadDone     ), 
    .rst         ( rst         )
);

always @(posedge w_fire_streamInstReadDone or negedge rst) begin
    if (!rst) begin
        INST_REG <= 128'b0;
        OP_REG   <= 8'b0;
    end else begin
        INST_REG <= RD_DATA[127:0];
        OP_REG <=RD_DATA[127:120];
    end
end



wire w_valid0_streamInst, w_valid1_streamInst, w_valid2_streamInst, w_valid3_streamInst, w_valid4_streamInst;
assign w_valid0_streamInst = (OP_REG == 8'h10); // 发送指令
assign w_valid1_streamInst = (OP_REG == 8'h11); // 发送数据
assign w_valid2_streamInst = (OP_REG == 8'h12); // 获取数据 
assign w_valid3_streamInst = (OP_REG == 8'h13); // 释放
assign w_valid4_streamInst = (OP_REG == 8'h14); // 获取状态
wire w_drive2_SEND_Inst, w_drive2_SEND_DATA,w_drive2_GET_DATA,w_drive2_FREE,w_drive2_GET_STATUS;
wire w_freeF_SEND_Inst, w_freeF_SEND_DATA,w_freeF_GET_DATA,w_freeF_FREE,w_freeF_GET_STATUS;
cSelSplit5_streamInst u_cSelSplit5_streamInst(
    .i_drive      ( w_drive_analyzeInst     ),
    .i_freeNext0  ( w_freeF_SEND_Inst  ),
    .i_freeNext1  ( w_freeF_SEND_DATA  ),
    .i_freeNext2  ( w_freeF_GET_DATA  ),
    .i_freeNext3  ( w_freeF_FREE  ),
    .i_freeNext4  ( w_freeF_GET_STATUS  ),
    .valid0       ( w_valid0_streamInst       ),
    .valid1       ( w_valid1_streamInst       ),
    .valid2       ( w_valid2_streamInst       ),
    .valid3       ( w_valid3_streamInst       ),
    .valid4       ( w_valid4_streamInst       ),
    .o_free       ( w_free_analyzeInst       ),
    .o_driveNext0 ( w_drive2_SEND_Inst ),
    .o_driveNext1 ( w_drive2_SEND_DATA ),
    .o_driveNext2 ( w_drive2_GET_DATA ),
    .o_driveNext3 ( w_drive2_FREE ),
    .o_driveNext4 ( w_drive2_GET_STATUS ),
    .rst          ( rst          )
);

//=========================================================================================================================================//
// MEM_SEND_INST
wire w_fire_MEM_SEND_Inst_FirstShake;
cFifo1_user MEM_SEND_INST_fifo0(
    .i_drive     ( w_drive2_SEND_Inst     ),
    .o_free      ( w_freeF_SEND_Inst      ),
    .o_driveNext ( w_driveF_MEM_SEND_Inst_FirstShake ),
    .i_freeNext  (  ),
    .o_fire      (      ), 
    .rst         ( rst         )
);



// read calculate inst
wire w_drive_readCalcInst;
wire w_free_readCalcInst;
cFifo1_user MEM_SEND_INST_fifo1(
    .i_drive     (      ),
    .o_free      (       ),
    .o_driveNext ( w_drive_readCalcInst ),
    .i_freeNext  ( w_free_readCalcInst ),
    .o_fire      (      ), 
    .rst         ( rst         )
);


// send claculate inst to TPU

cFifo1_user MEM_SEND_INST_fifo2(
    .i_drive     (      ),
    .o_free      (       ),
    .o_driveNext ( w_driveF_calcInst_to_TPU ),
    .i_freeNext  (  ),
    .o_fire      (      ), 
    .rst         ( rst         )
);





//=========================================================================================================================================//


//MEM_SEND_DATA
// send stream inst to TPU
wire w_driveF_MEM_SEND_DATA_FirstShake;
cFifo1_user MEM_SEND_DATA_fifo0(
    .i_drive     ( w_drive2_SEND_DATA     ),
    .o_free      ( w_freeF_SEND_DATA      ),
    .o_driveNext ( w_driveF_MEM_SEND_DATA_FirstShake ),
    .i_freeNext  (  ),
    .o_fire      (      ), 
    .rst         ( rst         )
);

// read matrix info 
wire w_drive2Read_matrixInfo;
cFifo1_user MEM_SEND_DATA_fifo1(
    .i_drive     (      ),
    .o_free      (       ),
    .o_driveNext ( w_drive2Read_matrixInfo ),
    .i_freeNext  (  ),
    .o_fire      (      ), 
    .rst         ( rst         )
);


//send matrix info to TPU
wire w_driveF_matrixInfo_to_TPU;
cFifo1_user MEM_SEND_DATA_fifo2(
    .i_drive     (      ),
    .o_free      (       ),
    .o_driveNext ( w_driveF_matrixInfo_to_TPU ),
    .i_freeNext  (  ),
    .o_fire      (      ), 
    .rst         ( rst         )
);




//=================================================================================================================//========================//

// MEM_GET_DATA
wire w_fire_MEM_GET_DATA_FirstShake;
cFifo1_user MEM_GET_DATA_fifo0(
    .i_drive     ( w_drive2_GET_DATA     ),
    .o_free      ( w_freeF_GET_DATA      ),
    .o_driveNext ( w_driveF_MEM_GET_DATA_FirstShake ),
    .i_freeNext  (  ),
    .o_fire      (      ), 
    .rst         ( rst         )
);

// read matrix id MEMGETDATA
wire w_drive2Read_matrixID_MEMGETDATA;
cFifo1_user MEM_GET_DATA_fifo1(
    .i_drive     (      ),
    .o_free      (       ),
    .o_driveNext ( w_drive2Read_matrixID_MEMGETDATA ),
    .i_freeNext  (  ),
    .o_fire      (      ), 
    .rst         ( rst         )
);

//send matrix id to TPU MEMGETDATA
wire w_driveF_matrixID_to_TPU_MEMGETDATA;
cFifo1_user MEM_GET_DATA_fifo2(
    .i_drive     (      ),
    .o_free      (       ),
    .o_driveNext ( w_driveF_matrixID_to_TPU_MEMGETDATA ),
    .i_freeNext  (  ),
    .o_fire      (      ), 
    .rst         ( rst         )
);


//==========================================================================================================================================//  

// MEM_FREE
wire w_fire_MEM_FREE_FirstShake;
cFifo1_user MEM_FREE_fifo0(
    .i_drive     ( w_drive2_FREE     ),
    .o_free      ( w_freeF_FREE      ),
    .o_driveNext ( w_driveF_MEM_FREE_FirstShake ),
    .i_freeNext  (  ),
    .o_fire      (      ), 
    .rst         ( rst         )
);

//read matrix id MEMFREE
wire w_drive2Read_matrixID_MEMFREE;
cFifo1_user MEM_FREE_fifo1(
    .i_drive     (      ),
    .o_free      (       ),
    .o_driveNext ( w_drive2Read_matrixID_MEMFREE ),
    .i_freeNext  (  ),
    .o_fire      (      ), 
    .rst         ( rst         )
);


wire w_driveF_matrixID_to_TPU_MEMFREE;
cFifo1_user MEM_FREE_fifo2(
    .i_drive     (      ),
    .o_free      (       ),
    .o_driveNext ( w_driveF_matrixID_to_TPU_MEMFREE ),
    .i_freeNext  (  ),
    .o_fire      (      ), 
    .rst         ( rst         )
);



//=========================================================================================================================================//

// MEM_GET_STATUS
wire w_fire_MEM_GET_STATUS_FirstShake;
cFifo1_user MEM_GET_STATUS_fifo0(
    .i_drive     ( w_drive2_GET_STATUS     ),
    .o_free      ( w_freeF_GET_STATUS      ),
    .o_driveNext ( w_driveF_MEM_GET_STATUS_FirstShake ),
    .i_freeNext  (  ),
    .o_fire      (      ), 
    .rst         ( rst         )
);




//============================================================================================================================================//


streamInstReader u_streamInstReader(

    .i_driveRead_0 ( w_drive_readStreamInst ),
    .o_freeRead_0  ( w_free_readStreamInst  ),
    .i_readAddr_0  (   ),
    .o_driveRead_0 ( w_drive_streamInstReadDone  ),
    .i_freeRead_0  ( w_free_streamInstReadDone  ),
    .o_readData_0  (   ),

    .i_driveRead_1 ( w_drive_readCalcInst ),
    .o_freeRead_1  ( w_free_readCalcInst  ),
    .i_readAddr_1  (   ),
    .o_driveRead_1 (  ),
    .i_freeRead_1  (   ),
    .o_readData_1  (   ),
    .i_driveRead_2 (  ),
    .o_freeRead_2  (   ),
    .i_readAddr_2  (   ),
    .o_driveRead_2 (  ),
    .i_freeRead_2  (   ),
    .o_readData_2  (   ),
    .i_driveRead_3 (  ),
    .o_freeRead_3  (   ),
    .i_readAddr_3  (   ),
    .o_driveRead_3 (  ),
    .i_freeRead_3  (   ),
    .o_readData_3  (   ),
    .i_driveRead_4 (  ),
    .o_freeRead_4  (   ),
    .i_readAddr_4  (   ),
    .o_driveRead_4 (  ),
    .i_freeRead_4  (   ),
    .i_driveRead_5 (  ),
    .i_readAddr_5  (   ),
    .o_driveRead_5 (  ),
    .i_freeRead_5  (   ),
    .o_readData_5  (   ),
    .i_driveRead_6 (  ),
    .o_freeRead_6  (   ),
    .i_readAddr_6  (   ),
    .o_driveRead_6 (  ),
    .i_freeRead_6  (   ),
    .o_readData_6  (   ),
    .i_driveRead_7 (  ),
    .o_freeRead_7  (   ),
    .i_readAddr_7  (   ),
    .o_driveRead_7 (  ),
    .i_freeRead_7  (   ),
    .o_readData_7  (   ),
    .i_driveRead_8 (  ),
    .o_freeRead_8  (   ),
    .i_readAddr_8  (   ),
    .o_driveRead_8 (  ),
    .i_freeRead_8  (   ),
    .o_readData_8  (   ),
    .RD_START      ( RD_START      ),
    .RD_ADDR       ( RD_ADDR       ),
    .RD_DATA       ( RD_DATA       ),
    .RD_DONE       ( RD_DONE       ),
    .rst           ( rst           )
);




//================================================================================================================================================//
// mutex merge for drive and data and finish to TPU





// TPU BACK
wire w_fire_saveTPU_data;
cFifo1_user MEM_GET_STATUS_fifo0(
    .i_drive     ( i_driveFTPU     ),
    .o_free      ( o_free2TPU      ),
    .o_driveNext (  ),
    .i_freeNext  (  ),
    .o_fire      (  w_fire_saveTPU_data    ), 
    .rst         ( rst         )
);

reg[128:0] TPU_data_finish_reg;
always @(posedge w_fire_saveTPU_data or negedge rst) begin
    if (!rst) begin
         TPU_data_finish_reg<= 129'b0;
    end else begin
         TPU_data_finish_reg<= {i_finishFTPU, i_dataFTPU_128};
    end
end


// select split for TPU drive and data and finish








endmodule