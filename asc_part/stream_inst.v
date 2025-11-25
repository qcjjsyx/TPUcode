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

localparam BASE_ADDR = 32'hC000_0000;
reg[31:0] read_addr_reg;

wire w_drive_readStreamInst, w_free_readStreamInst;
wire w_fire_readStreamInst
cFifo1_user read_StreamInst_fifo(
    .i_drive     ( CAN_READ_INST     ),
    .o_free      (       ),
    .o_driveNext ( w_drive_readStreamInst ),
    .i_freeNext  ( w_free_readStreamInst ),
    .o_fire      ( w_fire_readStreamInst    ), 
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
wire w_drive_handShake_MEM_SEND_INST;
wire w_free_handShake_MEM_SEND_INST;

cFifo1_user MEM_SEND_INST_fifo0(
    .i_drive     ( w_drive2_SEND_Inst     ),
    .o_free      ( w_freeF_SEND_Inst      ),
    .o_driveNext ( w_drive_handShake_MEM_SEND_INST ),
    .i_freeNext  ( w_free_handShake_MEM_SEND_INST ),
    .o_fire      (      ), 
    .rst         ( rst         )
);





// read calculate inst
wire w_drive_readCalcInst;
wire w_free_readCalcInst;
wire w_fire_readCalcInst;
cFifo1_user MEM_SEND_INST_fifo1(
    .i_drive     (      ),
    .o_free      (       ),
    .o_driveNext ( w_drive_readCalcInst ),
    .i_freeNext  ( w_free_readCalcInst ),
    .o_fire      ( w_fire_readCalcInst     ), 
    .rst         ( rst         )
);


// send claculate inst to TPU
wire w_drive_CalcInstReadDone;
wire w_free_CalcInstReadDone;
cFifo1_user MEM_SEND_INST_fifo2(
    .i_drive     ( w_drive_CalcInstReadDone     ),
    .o_free      ( w_free_CalcInstReadDone       ),
    .o_driveNext (  ),
    .i_freeNext  (  ),
    .o_fire      (      ), 
    .rst         ( rst         )
);





//=========================================================================================================================================//


//MEM_SEND_DATA
// send stream inst to TPU
wire w_drive_handShake_MEM_SEND_DATA;
wire w_free_handShake_MEM_SEND_DATA;
cFifo1_user MEM_SEND_DATA_fifo0(
    .i_drive     ( w_drive2_SEND_DATA     ),
    .o_free      ( w_freeF_SEND_DATA      ),
    .o_driveNext ( w_drive_handShake_MEM_SEND_DATA ),
    .i_freeNext  ( w_free_handShake_MEM_SEND_DATA ),
    .o_fire      (      ), 
    .rst         ( rst         )
);

// read matrix info 
wire w_drive_readMatrixInfo, w_free_readMatrixInfo;
wire w_fire_readMatrixInfo;
cFifo1_user MEM_SEND_DATA_fifo1(
    .i_drive     (      ),
    .o_free      (       ),
    .o_driveNext ( w_drive_readMatrixInfo ),
    .i_freeNext  ( w_free_readMatrixInfo ),
    .o_fire      ( w_fire_readMatrixInfo     ), 
    .rst         ( rst         )
);


//send matrix info to TPU
wire w_drive_matrixInfoReadDone, w_free_matrixInfoReadDone;
cFifo1_user MEM_SEND_DATA_fifo2(
    .i_drive     ( w_drive_matrixInfoReadDone     ),
    .o_free      ( w_free_matrixInfoReadDone      ),
    .o_driveNext (  ),
    .i_freeNext  (  ),
    .o_fire      (      ), 
    .rst         ( rst         )
);




//=================================================================================================================//========================//

// MEM_GET_DATA
wire w_drive_handShake_MEM_GET_DATA;
wire w_free_handShake_MEM_GET_DATA;
cFifo1_user MEM_GET_DATA_fifo0(
    .i_drive     ( w_drive2_GET_DATA     ),
    .o_free      ( w_freeF_GET_DATA      ),
    .o_driveNext ( w_drive_handShake_MEM_GET_DATA ),
    .i_freeNext  ( w_free_handShake_MEM_GET_DATA ),
    .o_fire      (      ), 
    .rst         ( rst         )
);

// read matrix id MEMGETDATA
wire w_drive_readMatrixId_MEMGETDATA, w_free_readMatrixId_MEMGETDATA;
wire w_fire_readMatrixId_MEMGETDATA;
cFifo1_user MEM_GET_DATA_fifo1(
    .i_drive     (      ),
    .o_free      (       ),
    .o_driveNext ( w_drive_readMatrixId_MEMGETDATA ),
    .i_freeNext  ( w_free_readMatrixId_MEMGETDATA ),
    .o_fire      ( w_fire_readMatrixId_MEMGETDATA     ), 
    .rst         ( rst         )
);

//send matrix id to TPU MEMGETDATA
wire w_drive_matrixIdReadDone_MEMGETDATA, w_free_matrixIdReadDone_MEMGETDATA;
cFifo1_user MEM_GET_DATA_fifo2(
    .i_drive     ( w_drive_matrixIdReadDone_MEMGETDATA     ),
    .o_free      ( w_free_matrixIdReadDone_MEMGETDATA     ),
    .o_driveNext (  ),
    .i_freeNext  (  ),
    .o_fire      (      ), 
    .rst         ( rst         )
);


//==========================================================================================================================================//  

// MEM_FREE
wire w_drive_handShake_MEM_FREE;
wire w_free_handShake_MEM_FREE;
cFifo1_user MEM_FREE_fifo0(
    .i_drive     ( w_drive2_FREE     ),
    .o_free      ( w_freeF_FREE      ),
    .o_driveNext ( w_drive_handShake_MEM_FREE ),
    .i_freeNext  ( w_drive_handShake_MEM_FREE ),
    .o_fire      (      ), 
    .rst         ( rst         )
);

//read matrix id MEMFREE
wire w_drive_readMatrixId_MEMFREE, w_free_readMatrixId_MEMFREE;
wire w_fire_
cFifo1_user MEM_FREE_fifo1(
    .i_drive     (      ),
    .o_free      (       ),
    .o_driveNext ( w_drive_readMatrixId_MEMFREE  ),
    .i_freeNext  ( w_free_readMatrixId_MEMFREE ),
    .o_fire      ( w_fire_readMatrixId_MEMFREE     ), 
    .rst         ( rst         )
);

//send matrix id to TPU MEMFREE
wire w_drive_matrixIdReadDone_MEMFREE, w_free_matrixIdReadDone_MEMFREE;
wire ;
cFifo1_user MEM_FREE_fifo2(
    .i_drive     ( w_drive_matrixIdReadDone_MEMFREE     ),
    .o_free      ( w_free_matrixIdReadDone_MEMFREE      ),
    .o_driveNext (   ),
    .i_freeNext  (  ),
    .o_fire      (      ), 
    .rst         ( rst         )
);



//=========================================================================================================================================//

// MEM_GET_STATUS
wire w_drive_handShake_MEM_GET_STATUS;
wire w_free_handShake_MEM_GET_STATUS;
cFifo1_user MEM_GET_STATUS_fifo0(
    .i_drive     ( w_drive2_GET_STATUS     ),
    .o_free      ( w_freeF_GET_STATUS      ),
    .o_driveNext ( w_drive_handShake_MEM_GET_STATUS ),
    .i_freeNext  ( w_free_handShake_MEM_GET_STATUS ),
    .o_fire      (      ), 
    .rst         ( rst         )
);




//============================================================================================================================================//
wire read_req;
assign read_req = w_fire_readStreamInst | w_fire_readCalcInst | w_fire_readMatrixInfo | w_fire_readMatrixId_MEMGETDATA | w_fire_readMatrixId_MEMFREE;
always @(posedge read_req or negedge rst) begin
    if (!rst) begin
        read_addr_reg <= BASE_ADDR;
    end else begin
        read_addr_reg <= read_addr_reg + 32'd16;// 每次读16字节
    end
end
wire w_rd_addr;
assign w_rd_addr = read_addr_reg;

streamInstReader u_streamInstReader(

    .rd_addr      ( w_rd_addr      ),
    .i_driveRead_0 ( w_drive_readStreamInst ),
    .o_freeRead_0  ( w_free_readStreamInst  ),
    // .i_readAddr_0  (   ),
    .o_driveRead_0 ( w_drive_streamInstReadDone  ),
    .i_freeRead_0  ( w_free_streamInstReadDone  ),
    .o_readData_0  (   ),

    .i_driveRead_1 ( w_drive_readCalcInst ),
    .o_freeRead_1  ( w_free_readCalcInst  ),
    // .i_readAddr_1  (   ),
    .o_driveRead_1 ( w_drive_CalcInstReadDone ),
    .i_freeRead_1  ( w_free_CalcInstReadDone ),
    .o_readData_1  (   ),

    .i_driveRead_2 ( w_drive_readMatrixInfo ),
    .o_freeRead_2  ( w_free_readMatrixInfo  ),
    // .i_readAddr_2  (   ),
    .o_driveRead_2 ( w_drive_matrixInfoReadDone ),
    .i_freeRead_2  ( w_free_matrixInfoReadDone  ),
    .o_readData_2  (   ),


    .i_driveRead_3 ( w_drive_readMatrixId_MEMGETDATA ),
    .o_freeRead_3  ( w_free_readMatrixId_MEMGETDATA  ),
    // .i_readAddr_3  (   ),
    .o_driveRead_3 ( w_drive_matrixIdReadDone_MEMGETDATA ),
    .i_freeRead_3  ( w_free_matrixIdReadDone_MEMGETDATA  ),
    .o_readData_3  (   ),


    .i_driveRead_4 ( w_drive_readMatrixId_MEMFREE  ),
    .o_freeRead_4  ( w_free_readMatrixId_MEMFREE  ),
    // .i_readAddr_4  (   ),
    .o_driveRead_4 ( w_drive_matrixIdReadDone_MEMFREE ),
    .i_freeRead_4  ( w_free_matrixIdReadDone_MEMFREE  ),
    .o_readData_4  (   ),


    .RD_START      ( RD_START      ),
    .RD_ADDR       ( RD_ADDR       ),
    .RD_DATA       ( RD_DATA       ),
    .RD_DONE       ( RD_DONE       ),
    .rst           ( rst           )
);




//================================================================================================================================================//
//  merge handshake from multiple sources to TPU
wire w_drive2TPU_handShake;
wire w_freeFTPU_handShake;
cMutexMerge5_streamInst u_cMutexMerge5_streamInst_handShake(
    .i_drive0     ( w_drive_handShake_MEM_SEND_INST     ),
    .o_free0      ( w_free_handShake_MEM_SEND_INST     ),
    .i_drive1     ( w_drive_handShake_MEM_SEND_DATA     ),
    .o_free1      ( w_free_handShake_MEM_SEND_DATA     ),
    .i_drive2     ( w_drive_handShake_MEM_GET_DATA     ),
    .o_free2      ( w_free_handShake_MEM_GET_DATA     ),
    .i_drive3     ( w_drive_handShake_MEM_FREE     ),
    .o_free3      ( w_free_handShake_MEM_FREE      ),
    .i_drive4     ( w_drive_handShake_MEM_GET_STATUS    ),
    .o_free4      ( w_free_handShake_MEM_GET_STATUS      ),
    .o_driveNext  (  w_drive2TPU_handShake  ),
    .i_freeNext   (  w_freeFTPU_handShake   ),
    .rst          ( rst          )
);



//================================================================================================================================================//
// mutex send data to TPU




//================================================================================================================================================//


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