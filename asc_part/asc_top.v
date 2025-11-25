module asc_top#
(
    parameter PACKET_SIZE = 256,
    parameter ADDR_WIDTH = 32
)
(
    (*dont_touch="true"*)output o_RD_START,
    (*dont_touch="true"*)output o_WR_START,
    (*dont_touch="true"*)output [ADDR_WIDTH-1:0] WR_ADDR,
    (*dont_touch="true"*)output [PACKET_SIZE-1:0] WR_DATA,
    (*dont_touch="true"*)output [ADDR_WIDTH-1:0] RD_ADDR,
    (*dont_touch="true"*)input [PACKET_SIZE-1:0] RD_DATA,

    (*dont_touch="true"*)input WR_DONE,
    input RD_DONE,

    // 1写0读
    input i_driveFMMU,
    output o_free2MMU,
    output o_drive2MMU,
    input i_freeFromMMU,

    input wen,
    input [ADDR_WIDTH-1:0] addr,
    //WRITE
    input [PACKET_SIZE-1:0] wdata,
    //READ
    output [PACKET_SIZE-1:0] rdata,

    input rst


);



wire w_fire_taskdone;
wire w_driveRead, w_driveWrite;
wire w_freeRead, w_freeWrite;
cSelSplit2_user u_cSelSplit2_user(
    .i_drive      ( i_driveFMMU      ),
    .i_freeNext0  ( w_freeRead  ),
    .i_freeNext1  ( w_freeWrite  ),
    .valid0       ( ~wen       ),
    .valid1       ( wen       ),
    .o_free       ( o_free2MMU       ),
    .o_driveNext0 ( w_driveRead ),
    .o_driveNext1 ( w_driveWrite ),
    .rst          ( rst          )
);

wire w_fireRead, w_fireWrite;
cFifo1_user u_cFifo1_Read(
    .i_drive     ( w_driveRead    ),
    .o_free      ( w_freeRead      ),
    .o_driveNext (  ),
    .i_freeNext  ( w_fireRead  ),
    .o_fire      ( w_fireRead      ),
    .rst         ( rst         )
);

reg RD_START_REG;
reg [ADDR_WIDTH-1:0] RD_ADDR_REG;
// Modified for Asynchronous Handshake: Set by w_fireRead, Reset by RD_DONE (ACK)
always @(posedge w_fireRead or posedge RD_DONE or negedge rst) begin
    if (!rst) begin
        RD_START_REG <= 1'b0;
        RD_ADDR_REG  <= {ADDR_WIDTH{1'b0}};
    end else if (RD_DONE) begin
        RD_START_REG <= 1'b0;
    end else begin
        RD_START_REG <= 1'b1;
        RD_ADDR_REG  <= addr;
    end
end

    
assign o_RD_START = RD_START_REG;
wire w_fireWrite_delayed;
cFifo1_user u_cFifo1_Write(
    .i_drive     ( w_driveWrite    ),
    .o_free      ( w_freeWrite      ),
    .o_driveNext (  ),
    .i_freeNext  ( w_fireWrite_delayed  ),
    .o_fire      ( w_fireWrite      ),
    .rst         ( rst         )
);

delay2U u_delay2U(
    .inR  ( w_fireWrite  ),
    .outR ( w_fireWrite_delayed ),
    .rst  ( rst  )
);

(*keep = "true"*)reg WR_START_REG;
reg [ADDR_WIDTH-1:0] WR_ADDR_REG;
reg[PACKET_SIZE-1:0] WR_DATA_REG;
// Modified for Asynchronous Handshake: Set by w_fireWrite, Reset by WR_DONE (ACK)
always @(posedge w_fireWrite or posedge WR_DONE or negedge rst) begin
    if (!rst) begin
        WR_START_REG <= 1'b0;
        WR_ADDR_REG  <= {ADDR_WIDTH{1'b0}};
        WR_DATA_REG  <= {PACKET_SIZE{1'b0}};
    end else if (WR_DONE) begin
        WR_START_REG <= 1'b0;
    end else begin
        WR_START_REG <= 1'b1;
        WR_ADDR_REG  <= addr;
        WR_DATA_REG  <= wdata;
    end
end

assign o_WR_START = WR_START_REG;

assign WR_ADDR = WR_ADDR_REG;
assign WR_DATA = WR_DATA_REG;
assign RD_ADDR = RD_ADDR_REG;
assign rdata = RD_DATA;

wire w_drive_taskdone, w_free_taskdone;
cMutexMerge2_user u_cMutexMerge2_user(
    .i_drive0     ( RD_DONE     ),
    .o_free0      (       ),
    .i_drive1     ( WR_DONE     ),
    .o_free1      (       ),
    .o_driveNext  ( w_drive_taskdone  ),
    .i_freeNext   ( w_free_taskdone   ),
    .rst          ( rst          )
);

cFifo1_user u_cFifo1_taskdone(
    .i_drive     ( w_drive_taskdone     ),
    .o_free      ( w_free_taskdone      ),
    .o_driveNext ( o_drive2MMU ),
    .i_freeNext  ( i_freeFromMMU  ),
    .o_fire      ( w_fire_taskdone      ),
    .rst         ( rst         )
);
// (*keep="yes"*)reg[PACKET_SIZE-1:0] rd_data_reg;
// always @(posedge w_fire_taskdone or negedge rst) begin
//     if(!rst) begin
//         rd_data_reg <= {PACKET_SIZE{1'b0}};
//     end
//     else begin
//         rd_data_reg <= RD_DATA;
//     end
// end
// assign rdata = rd_data_reg;






endmodule