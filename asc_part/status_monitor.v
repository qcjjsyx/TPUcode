module status_monitor(



    
    // 清空任务数中断
    input ReadFinishInter,
    // bram 写
    output reg WR_START,
    output reg[31:0] WR_ADDR,
    output reg[63:0] WR_DATA,
    input WR_DONE,

    input  ACLK,
    input ARESETN
);

reg[7:0] reg_num_finishtask;

//清空任务数
always @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) begin
        reg_num_finishtask <= 8'b0;
    end
    else begin
        if(ReadFinishInter) begin
            reg_num_finishtask <= 8'b0;
        end else begin
            reg_num_finishtask <= reg_num_finishtask;
        end
    end
end
//写 bram 任务数
always @(posedge ACLK or negedge ARESETN ) begin
    if(!ARESETN) begin
        WR_START <= 1'b0;
        WR_ADDR  <= 32'b0;
        WR_DATA  <= 64'b0;
    end
    else begin
        if(WR_DONE) begin
            WR_START <= 1'b0; // 写完成后清除启动信号
        end else if(ReadFinishInter) begin // 清空所有任务数
            WR_START <= 1'b1;
            WR_ADDR  <= 32'b0; // 假设从地址0开始写
            WR_DATA  <= 64'b0; 
        end else begin
            WR_START <= WR_START;
            WR_ADDR  <= WR_ADDR;
            WR_DATA  <= WR_DATA;
        end
        
    end
end


endmodule