module stream_inst(
    // Control Signals
    input CAN_READ_INST,
    output FINISH,

    // mover Interface

    // BRAM READ Interface
    output RD_START,
    output[31:0] RD_ADDR,
    input[127:0] RD_DATA,
    input RD_DONE,

    // TPU Interface
    output o_drive2TPU,
    input  i_freeFTPU,
    output[127:0] o_streamInst_data_128,
    output o_finish2TPU,

    input i_driveFTPU,
    output o_freeFTPU,
    input[127:0] i_TPU_data_128,
    input i_finishFTPU,

    input rst

);

wire w_readInst_fire, w_readInst_fire_delay;


cFifo1_user read_inst_fifo(
    .i_drive     ( CAN_READ_INST     ),
    .o_free      (       ),
    .o_driveNext (  ),
    .i_freeNext  ( w_readInst_fire_delay  ),
    .o_fire      ( w_readInst_fire     ), 
    .rst         ( rst         )
);
delay2U readInst_delay2U(
    .inR  ( w_readInst_fire  ),
    .outR ( w_readInst_fire_delay ),
    .rst  ( rst  )
);
// 读出指令
always @(posedge w_readInst_fire or posedge RD_DONE or negedge rst) begin
    if (!rst) begin
        RD_START_REG <= 1'b0;
        RD_ADDR_REG  <= 32'b0;
    end else if (RD_DONE) begin
        RD_START_REG <= 1'b0;
    end else begin
        RD_START_REG <= 1'b1;
        RD_ADDR_REG  <= 32'hC000_0000; // 假设指令地址为C000_0000
    end
end

// 锁存指令
wire w_inst_fire;
wire w_drive_analyzeInst;
wire w_freeFAnalyzeInst;
reg [127:0] INST_REG;
reg[7:0] OP_REG;
cFifo1_user read_inst_fifo(
    .i_drive     ( RD_DONE     ),
    .o_free      (       ),
    .o_driveNext ( w_drive_analyzeInst ),
    .i_freeNext  ( w_freeFAnalyzeInst ),
    .o_fire      ( w_inst_fire     ), 
    .rst         ( rst         )
);

always @(posedge w_inst_fire or negedge rst) begin
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
    .i_drive      ( w_drive_analyzeInst      ),
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
    .o_free       ( w_freeFAnalyzeInst       ),
    .o_driveNext0 ( w_drive2_SEND_Inst ),
    .o_driveNext1 ( w_drive2_SEND_DATA ),
    .o_driveNext2 ( w_drive2_GET_DATA ),
    .o_driveNext3 ( w_drive2_FREE ),
    .o_driveNext4 ( w_drive2_GET_STATUS ),
    .rst          ( rst          )
);









endmodule