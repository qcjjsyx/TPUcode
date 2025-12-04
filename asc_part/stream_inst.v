module stream_inst(
    // Control Signals
    input CAN_READ_INST,
    output FINISH,
    output STATUS_SEND,
    output[127:0] STATUS_INFO,


    // BRAM READ Interface
    output RD_START,
    output [31:0] RD_ADDR,
    input [127:0] RD_DATA,
    input RD_DONE,


    // mover1 Interface MEM_SEND_DATA
    output o_drive2Mover1,
    input  i_freeF_Mover1,
    output[119:0] o_data2Mover1,


    // mover2 Interface MEM_GET_DATA
    output o_drive2Mover2,
    input  i_freeF_Mover2,
    output[89:0] o_data2Mover2,

    // TPU Interface
    output o_drive2TPU,
    input  i_freeFTPU,
    output[127:0] o_data2TPU_128,
    output o_finish2TPU,

    input i_driveFTPU,
    output o_free2TPU,
    input[127:0] i_dataFTPU_128,
    input i_finishFTPU,

    input i_driveFTPU_STATUS,
    output o_free2TPU_STATUS,
    input[127:0] i_dataFTPU_STATUS,

    input rst

);

localparam BASE_ADDR = 32'hC000_0000;
reg[31:0] read_addr_reg;

wire w_drive_readStreamInst, w_free_readStreamInst;
wire w_fire_readStreamInst;
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
wire [127:0] w_data_streamInst;
reg [127:0] STREAM_INST_REG;
reg[7:0] OP_REG;
reg[7:0] DATA_NUM_REG; 
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
        STREAM_INST_REG <= 128'b0;
        OP_REG   <= 8'b0;
        DATA_NUM_REG <= 8'b0;
    end else begin
        STREAM_INST_REG <= w_data_streamInst;
        OP_REG <= w_data_streamInst[127:120];
        DATA_NUM_REG <= w_data_streamInst[119:96];
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
// MEM_SEND_INST handshake
cFifo1_user MEM_SEND_INST_fifo0(
    .i_drive     ( w_drive2_SEND_Inst     ),
    .o_free      ( w_freeF_SEND_Inst      ),
    .o_driveNext ( w_drive_handShake_MEM_SEND_INST ),
    .i_freeNext  ( w_free_handShake_MEM_SEND_INST ),
    .o_fire      (      ), 
    .rst         ( rst         )
);





// read calculate inst
wire w_drive_startReadCalcInst, w_free_startReadCalcInst;
wire w_drive_readCalcInst;
wire w_free_readCalcInst;
wire w_fire_readCalcInst;
cFifo1_user MEM_SEND_INST_fifo1(
    .i_drive     ( w_drive_startReadCalcInst     ),
    .o_free      ( w_free_startReadCalcInst      ),
    .o_driveNext ( w_drive_readCalcInst ),
    .i_freeNext  ( w_free_readCalcInst ),
    .o_fire      ( w_fire_readCalcInst     ), 
    .rst         ( rst         )
);


// send claculate inst to TPU
wire w_drive_CalcInstReadDone;
wire w_free_CalcInstReadDone;
wire w_fire_CalcInstReadDone;
wire w_drive_sendCalcInst;
wire w_free_sendCalcInst;
wire [127:0] w_data_CalcInst;
cFifo1_user MEM_SEND_INST_fifo2(
    .i_drive     ( w_drive_CalcInstReadDone     ),
    .o_free      ( w_free_CalcInstReadDone       ),
    .o_driveNext ( w_drive_sendCalcInst ),
    .i_freeNext  ( w_free_sendCalcInst ),
    .o_fire      ( w_fire_CalcInstReadDone     ), 
    .rst         ( rst         )
);
reg[127:0] CALC_INST_REG;
always @(posedge w_fire_CalcInstReadDone or negedge rst) begin
    if (!rst) begin
        CALC_INST_REG <= 128'b0;
    end else begin
        CALC_INST_REG <= w_data_CalcInst;
    end
end
// wire[127:0] w_calcInst;
// assign w_calcInst = CALC_INST_REG;



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
wire w_drive_startReadMatrixInfo, w_free_startReadMatrixInfo;
wire w_drive_readMatrixInfo, w_free_readMatrixInfo;
wire w_fire_readMatrixInfo;
cFifo1_user MEM_SEND_DATA_fifo1(
    .i_drive     ( w_drive_startReadMatrixInfo     ),
    .o_free      ( w_free_startReadMatrixInfo      ),
    .o_driveNext ( w_drive_readMatrixInfo ),
    .i_freeNext  ( w_free_readMatrixInfo ),
    .o_fire      ( w_fire_readMatrixInfo     ), 
    .rst         ( rst         )
);


//send matrix info to TPU
wire w_drive_matrixInfoReadDone, w_free_matrixInfoReadDone;
wire w_drive_sendMatrixInfo;
wire w_free_sendMatrixInfo;
wire w_fire_matrixInfoReadDone;
wire[127:0] w_data_matrixInfo;
reg[127:0] MATRIX_INFO_REG;

cFifo1_user MEM_SEND_DATA_fifo2(
    .i_drive     ( w_drive_matrixInfoReadDone     ),
    .o_free      ( w_free_matrixInfoReadDone      ),
    .o_driveNext ( w_drive_sendMatrixInfo ),
    .i_freeNext  ( w_free_sendMatrixInfo ),
    .o_fire      ( w_fire_matrixInfoReadDone     ), 
    .rst         ( rst         )
);

always @(posedge w_fire_matrixInfoReadDone or negedge rst) begin
    if (!rst) begin
        MATRIX_INFO_REG <= 128'b0;
    end else begin
        MATRIX_INFO_REG <= w_data_matrixInfo;
    end
end


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
wire w_drive_startReadMatrixId_MEMGETDATA, w_free_startReadMatrixId_MEMGETDATA;
wire w_drive_readMatrixId_MEMGETDATA, w_free_readMatrixId_MEMGETDATA;
wire w_fire_readMatrixId_MEMGETDATA;
cFifo1_user MEM_GET_DATA_fifo1(
    .i_drive     ( w_drive_startReadMatrixId_MEMGETDATA     ),
    .o_free      ( w_free_startReadMatrixId_MEMGETDATA      ),
    .o_driveNext ( w_drive_readMatrixId_MEMGETDATA ),
    .i_freeNext  ( w_free_readMatrixId_MEMGETDATA ),
    .o_fire      ( w_fire_readMatrixId_MEMGETDATA     ), 
    .rst         ( rst         )
);

//send matrix id to TPU MEMGETDATA
wire w_drive_matrixIdReadDone_MEMGETDATA, w_free_matrixIdReadDone_MEMGETDATA;
wire w_drive_sendMaxtrixId_MEMGETDATA;
wire w_free_sendMaxtrixId_MEMGETDATA;
wire w_fire_matrixIdReadDone_MEMGETDATA;
wire[127:0] w_data_matrixId_MEMGETDATA;
reg[127:0] MATRIX_ID_MEMGETDATA_REG;
cFifo1_user MEM_GET_DATA_fifo2(
    .i_drive     ( w_drive_matrixIdReadDone_MEMGETDATA     ),
    .o_free      ( w_free_matrixIdReadDone_MEMGETDATA     ),
    .o_driveNext ( w_drive_sendMaxtrixId_MEMGETDATA ),
    .i_freeNext  ( w_free_sendMaxtrixId_MEMGETDATA ),
    .o_fire      ( w_fire_matrixIdReadDone_MEMGETDATA     ), 
    .rst         ( rst         )
);
always @(posedge w_fire_matrixIdReadDone_MEMGETDATA or negedge rst) begin
    if (!rst) begin
        MATRIX_ID_MEMGETDATA_REG <= 128'b0;
    end else begin
        MATRIX_ID_MEMGETDATA_REG <= w_data_matrixId_MEMGETDATA;
    end
end

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
wire w_drive_startReadMatrixId_MEMFREE, w_free_startReadMatrixId_MEMFREE;
wire w_drive_readMatrixId_MEMFREE, w_free_readMatrixId_MEMFREE;
wire w_fire_readMatrixId_MEMFREE;
cFifo1_user MEM_FREE_fifo1(
    .i_drive     ( w_drive_startReadMatrixId_MEMFREE     ),
    .o_free      ( w_free_startReadMatrixId_MEMFREE      ),
    .o_driveNext ( w_drive_readMatrixId_MEMFREE  ),
    .i_freeNext  ( w_free_readMatrixId_MEMFREE ),
    .o_fire      ( w_fire_readMatrixId_MEMFREE     ), 
    .rst         ( rst         )
);

//send matrix id to TPU MEMFREE
wire w_drive_matrixIdReadDone_MEMFREE, w_free_matrixIdReadDone_MEMFREE;
wire w_drive_sendMaxtrixId_MEMFREE;
wire w_free_sendMaxtrixId_MEMFREE;
wire w_fire_matrixIdReadDone_MEMFREE;
wire[127:0] w_data_matrixId_MEMFREE;
reg[127:0] MATRIX_ID_MEMFREE_REG;
cFifo1_user MEM_FREE_fifo2(
    .i_drive     ( w_drive_matrixIdReadDone_MEMFREE     ),
    .o_free      ( w_free_matrixIdReadDone_MEMFREE      ),
    .o_driveNext ( w_drive_sendMaxtrixId_MEMFREE ),
    .i_freeNext  ( w_free_sendMaxtrixId_MEMFREE ),
    .o_fire      ( w_fire_matrixIdReadDone_MEMFREE     ), 
    .rst         ( rst         )
);
always @(posedge w_fire_matrixIdReadDone_MEMFREE or negedge rst) begin
    if (!rst) begin
        MATRIX_ID_MEMFREE_REG <= 128'b0;
    end else begin
        MATRIX_ID_MEMFREE_REG <= w_data_matrixId_MEMFREE;
    end
end


//=========================================================================================================================================//

// // MEM_GET_STATUS
// wire w_drive_handShake_MEM_GET_STATUS;
// wire w_free_handShake_MEM_GET_STATUS;
// cFifo1_user MEM_GET_STATUS_fifo0(
//     .i_drive     ( w_drive2_GET_STATUS     ),
//     .o_free      ( w_freeF_GET_STATUS      ),
//     .o_driveNext ( w_drive_handShake_MEM_GET_STATUS ),
//     .i_freeNext  ( w_free_handShake_MEM_GET_STATUS ),
//     .o_fire      (      ), 
//     .rst         ( rst         )
// );




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

    .o_driveRead_0 ( w_drive_streamInstReadDone  ),
    .i_freeRead_0  ( w_free_streamInstReadDone  ),
    .o_readData_0  ( w_data_streamInst  ),

    .i_driveRead_1 ( w_drive_readCalcInst ),
    .o_freeRead_1  ( w_free_readCalcInst  ),
    .o_driveRead_1 ( w_drive_CalcInstReadDone ),
    .i_freeRead_1  ( w_free_CalcInstReadDone ),
    .o_readData_1  ( w_data_CalcInst  ),

    .i_driveRead_2 ( w_drive_readMatrixInfo ),
    .o_freeRead_2  ( w_free_readMatrixInfo  ),
    .o_driveRead_2 ( w_drive_matrixInfoReadDone ),
    .i_freeRead_2  ( w_free_matrixInfoReadDone  ),
    .o_readData_2  ( w_data_matrixInfo  ),


    .i_driveRead_3 ( w_drive_readMatrixId_MEMGETDATA ),
    .o_freeRead_3  ( w_free_readMatrixId_MEMGETDATA  ),
    .o_driveRead_3 ( w_drive_matrixIdReadDone_MEMGETDATA ),
    .i_freeRead_3  ( w_free_matrixIdReadDone_MEMGETDATA  ),
    .o_readData_3  ( w_data_matrixId_MEMGETDATA  ),


    .i_driveRead_4 ( w_drive_readMatrixId_MEMFREE  ),
    .o_freeRead_4  ( w_free_readMatrixId_MEMFREE  ),
    .o_driveRead_4 ( w_drive_matrixIdReadDone_MEMFREE ),
    .i_freeRead_4  ( w_free_matrixIdReadDone_MEMFREE  ),
    .o_readData_4  ( w_data_matrixId_MEMFREE  ),


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
cMutexMerge4_streamInst u_cMutexMerge4_streamInst_handShake(
    .i_drive0     ( w_drive_handShake_MEM_SEND_INST     ),
    .o_free0      ( w_free_handShake_MEM_SEND_INST     ),
    .i_drive1     ( w_drive_handShake_MEM_SEND_DATA     ),
    .o_free1      ( w_free_handShake_MEM_SEND_DATA     ),
    .i_drive2     ( w_drive_handShake_MEM_GET_DATA     ),
    .o_free2      ( w_free_handShake_MEM_GET_DATA     ),
    .i_drive3     ( w_drive_handShake_MEM_FREE     ),
    .o_free3      ( w_free_handShake_MEM_FREE      ),
    .o_driveNext  (  w_drive2TPU_handShake  ),
    .i_freeNext   (  w_freeFTPU_handShake   ),
    .rst          ( rst          )
);



//================================================================================================================================================//
// mutex send data to TPU

wire w_drive2TPU_sendData;
wire w_freeFTPU_sendData;
wire [127:0] w_data2TPU_sendData;

cMutexMerge4_d_streamInst #(
    .DATA_WIDTH ( 128 )
)u_cMutexMerge4_d_streamInst(
    .i_drive0     ( w_drive_sendCalcInst     ),
    .o_free0      ( w_free_sendCalcInst      ),
    .i_data0      ( CALC_INST_REG      ),
    .i_drive1     ( w_drive_sendMatrixInfo     ),
    .o_free1      ( w_free_sendMatrixInfo      ),
    .i_data1      ( MATRIX_INFO_REG      ),
    .i_drive2     ( w_drive_sendMaxtrixId_MEMGETDATA     ),
    .o_free2      ( w_free_sendMaxtrixId_MEMGETDATA      ),
    .i_data2      ( MATRIX_ID_MEMGETDATA_REG      ),
    .i_drive3     ( w_drive_sendMaxtrixId_MEMFREE     ),
    .o_free3      ( w_free_sendMaxtrixId_MEMFREE      ),
    .i_data3      ( MATRIX_ID_MEMFREE_REG      ),
    .o_driveNext  ( w_drive2TPU_sendData   ),
    .i_freeNext   ( w_freeFTPU_sendData    ),
    .o_data       ( w_data2TPU_sendData        ),
    .rst          ( rst          )
);
wire w_fire_sendData;
wire w_drive_sendDataDelayed;
wire wire_free_sendDataDelayed;
cFifo1_user u_cFifo1_user_sendData(
    .i_drive     ( w_drive2TPU_sendData     ),
    .o_free      ( w_free2TPU_sendData      ),
    .o_driveNext ( w_drive_sendDataDelayed ),
    .i_freeNext  ( wire_free_sendDataDelayed  ),
    .o_fire      ( w_fire_sendData      ),
    .rst         ( rst         )
);
reg[127:0] data2TPU_reg;
always @(posedge w_fire_sendData or negedge rst) begin
    if (!rst) begin
        data2TPU_reg <= 128'b0;
    end else begin
        data2TPU_reg <= w_data2TPU_sendData;
    end
end




//================================================================================================================================================//
// mutex merge handshake and send data to TPU
wire w_drive2TPU, w_freeFTPU;
wire[127:0] w_data2TPU;
cMutexMerge2_d_streamInst #(
    .DATA_WIDTH   ( 128 )
)u_cMutexMerge2_d_streamInst(
    .i_drive0     ( w_drive2TPU_handShake     ),
    .o_free0      ( w_freeFTPU_handShake      ),
    .i_data0      ( {128'b0,OP_REG}      ),
    .i_drive1     ( w_drive_sendDataDelayed     ),
    .o_free1      ( wire_free_sendDataDelayed       ),
    .i_data1      ( data2TPU_reg      ),
    .o_driveNext  ( w_drive2TPU  ),
    .i_freeNext   ( w_freeFTPU    ),
    .o_data       (  w_data2TPU      ),
    .rst          ( rst          )
);
wire w_fire0;
cFifo1_user u_cFifo1_user_drive2TPU(
    .i_drive     ( w_drive2TPU    ),
    .o_free      ( w_freeFTPU       ),
    .o_driveNext ( o_drive2TPU ),
    .i_freeNext  ( i_freeFTPU  ),
    .o_fire      ( w_fire0      ),
    .rst         ( rst          )
);

reg[127:0] r_o_data2TPU;
reg r_o_finish2TPU;
reg[7:0] send_cnt;
assign o_data2TPU_128 = r_o_data2TPU;
assign o_finish2TPU = r_o_finish2TPU;
always @(posedge w_fire0 or negedge rst) begin
    if (!rst) begin
        r_o_data2TPU <= 128'b0;
        r_o_finish2TPU <= 1'b0;
        send_cnt <= 8'b0;
    end else begin
        r_o_data2TPU <= w_data2TPU;
        r_o_finish2TPU <= (send_cnt == DATA_NUM_REG ) ? 1'b1 : 1'b0; //handshake 也计入
        if (send_cnt == DATA_NUM_REG ) begin
            send_cnt <= 8'b0;
        end else begin
            send_cnt <= send_cnt + 1'b1;
        end 
    end
end







//=================================================================================================================================================//

// TPU BACK
wire w_fire_saveTPU_data;
wire w_drive2_selSplit2, w_freeF_selSplit2;
wire w_drive2_natSplit2, w_freeF_natSplit2;
cFifo1_user MEM_GET_STATUS_fifo0(
    .i_drive     ( i_driveFTPU     ),
    .o_free      ( o_free2TPU      ),
    .o_driveNext ( w_drive2_natSplit2 ),
    .i_freeNext  ( w_freeF_natSplit2 ),
    .o_fire      (  w_fire_saveTPU_data    ), 
    .rst         ( rst         )
);

reg[2:0] r_matrixNum;
reg[119:0] r_maxtrixAddr;
reg[89:0] r_matrixInfo;
reg r_i_finishFTPU;
always @(posedge w_fire_saveTPU_data or negedge rst) begin
    if (!rst) begin
        r_matrixNum <= 3'b0;
        r_i_finishFTPU <= 1'b0;
    end else begin
        r_matrixNum <= i_dataFTPU_128[127:126];
        r_maxtrixAddr <= i_dataFTPU_128[119:0];
        r_matrixInfo <= i_dataFTPU_128[89:0];
        r_i_finishFTPU <= i_finishFTPU;
    end 
end
assign o_data2Mover1 = r_maxtrixAddr;
assign o_data2Mover2 = r_matrixInfo;

wire w_drive2_selSplit3;
wire w_freeF_selSplit3;
cNatSplit2_user u_cNatSplit2_user(
    .i_drive      ( w_drive2_natSplit2      ),
    .i_freeNext0  ( w_freeF_selSplit2  ),
    .i_freeNext1  ( w_freeF_selSplit3  ),
    .o_free       ( w_freeF_natSplit2       ),
    .o_driveNext0 ( w_drive2_selSplit2 ),
    .o_driveNext1 ( w_drive2_selSplit3 ),
    .rst          ( rst          )
);

wire w_drive_EMPTY, w_drive_EMPTY_delayed;
cSelSplit3_streamInst u_cSelSplit3_streamInst(
    .i_drive      ( w_drive2_selSplit3      ),
    .i_freeNext0  ( i_freeF_Mover1  ),
    .i_freeNext1  ( i_freeF_Mover2  ),
    .i_freeNext2  ( w_drive_EMPTY_delayed  ),
    .valid0       ( (OP_REG==8'h11)&&~(r_matrixNum==2'b0)       ),
    .valid1       ( (OP_REG==8'h12)&&~(r_matrixNum==2'b0)       ),
    .valid2       ( (!(OP_REG==8'h11) && !(OP_REG==8'h12))||(r_matrixNum==2'b0) ),
    .o_free       ( w_freeF_selSplit3       ),
    .o_driveNext0 ( o_drive2Mover1 ),
    .o_driveNext1 ( o_drive2Mover2 ),
    .o_driveNext2 ( w_drive_EMPTY ),
    .rst          ( rst          )
);

delay1U u_delay1U_EMPTY(
    .inR  ( w_drive_EMPTY  ),
    .outR ( w_drive_EMPTY_delayed ),
    .rst  ( rst  )
);

// 先一分2，判断是否要继续读取发送
wire w_drive_FINISH;
wire w_free_FINISH;

wire w_drive_startReadData;
wire w_free_startReadData;
cSelSplit2_user u_cSelSplit2_user(
    .i_drive      ( w_drive2_selSplit2      ),
    .i_freeNext0  ( w_free_startReadData  ),
    .i_freeNext1  ( w_free_FINISH  ),
    .valid0       ( (r_i_finishFTPU==1'b0)       ),
    .valid1       ( (r_i_finishFTPU==1'b1)       ),
    .o_free       ( w_freeF_selSplit2       ),
    .o_driveNext0 ( w_drive_startReadData ),
    .o_driveNext1 ( w_drive_FINISH  ),
    .rst          ( rst          )
);

delay4U u_delay4U_finish(
    .inR  ( w_drive_FINISH  ),
    .outR ( w_free_FINISH ),
    .rst  ( rst  )
);
assign FINISH = w_drive_FINISH;
//==================================================================================================================================================//





//======================================================================================================================================//

//再一分四
cSelSplit4_streamInst u_cSelSplit4_streamInst(
    .i_drive      ( w_drive_startReadData     ),
    .i_freeNext0  ( w_free_startReadCalcInst  ),
    .i_freeNext1  ( w_free_startReadMatrixInfo  ),
    .i_freeNext2  ( w_free_startReadMatrixId_MEMGETDATA  ),
    .i_freeNext3  ( w_free_startReadMatrixId_MEMFREE  ),
    .valid0       ( (OP_REG==8'h10)       ),
    .valid1       ( (OP_REG==8'h11)       ),
    .valid2       ( (OP_REG==8'h12)       ),
    .valid3       ( (OP_REG==8'h13)       ),
    .o_free       ( w_free_startReadData      ),
    .o_driveNext0 ( w_drive_startReadCalcInst ),
    .o_driveNext1 ( w_drive_startReadMatrixInfo ),
    .o_driveNext2 ( w_drive_startReadMatrixId_MEMGETDATA ),
    .o_driveNext3 ( w_drive_startReadMatrixId_MEMFREE ),
    .rst          ( rst          )
);

//===================================================================================================================================================//
// GET STATUS
reg[127:0] STATUS_INFO_REG;
assign STATUS_INFO = STATUS_INFO_REG;
wire w_fire_STATUS,w_fire_STATUS_delayed;
cFifo1_user u_cFifo1_user(
    .i_drive     ( i_driveFTPU_STATUS     ),
    .o_free      ( o_free2TPU_STATUS      ),
    .o_driveNext ( STATUS_SEND ),
    .i_freeNext  (   ),
    .o_fire      ( w_fire_STATUS      ),
    .rst         ( rst         )
);
delay1U u_delay1U_STATUS(
    .inR  ( w_fire_STATUS  ),
    .outR ( w_fire_STATUS_delayed ),
    .rst  ( rst  )
);
always @(posedge w_fire_STATUS or negedge rst) begin
    if (!rst) begin
        STATUS_INFO_REG <= 128'b0;
    end else begin
        STATUS_INFO_REG <= i_dataFTPU_STATUS;
    end
end


//====================================================================================================================================================//

endmodule