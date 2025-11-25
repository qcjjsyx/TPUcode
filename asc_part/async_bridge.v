module async_bridge (
    input  wire         clk,            // AXI 时钟 (ACLK)
    input  wire         rst_n,          // AXI 复位 (ARESETN)

    // -------------------------------------------------------------------------
    // 写通道 (异步 -> 同步)
    // -------------------------------------------------------------------------
    input  wire         async_wr_req,   // 异步写请求
    input  wire [31:0]  async_wr_addr,  // 异步写地址
    input  wire [255:0] async_wr_data,  // 异步写数据
    output reg          async_wr_ack,   // 写完成握手

    output reg          synced_wr_start, // 同步后的写脉冲
    output reg  [31:0]  synced_wr_addr,  // 同步后的写地址
    output reg  [255:0] synced_wr_data,  // 同步后的写数据
    
    input  wire         axi_wr_done,     // 来自 ddr_controller 的写完成信号

    // -------------------------------------------------------------------------
    // 读通道 (异步 -> 同步 -> 异步)
    // -------------------------------------------------------------------------
    input  wire         async_rd_req,   // 异步读请求
    input  wire [31:0]  async_rd_addr,  // 异步读地址
    (*dont_touch="true"*)output [255:0] async_rd_data,  // [新增] 返回给异步模块的读数据
    output reg          async_rd_ack,   // [新增] 读完成握手

    output reg          synced_rd_start, // [新增] 同步后的读脉冲
    output reg  [31:0]  synced_rd_addr,  // [新增] 同步后的读地址
    
    (*keep="yes"*)input  wire         axi_rd_done,     // [新增] 来自 ddr_controller 的读完成信号
    (*keep="yes"*)input  wire [255:0] axi_rd_data      // [新增] 来自 ddr_controller 的读数据
);

    // =========================================================================
    // 写通道逻辑 (保持不变)
    // =========================================================================
    
    // 1. 信号同步
    reg wr_req_d1, wr_req_d2, wr_req_d3;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_req_d1 <= 1'b0; wr_req_d2 <= 1'b0; wr_req_d3 <= 1'b0;
        end else begin
            wr_req_d1 <= async_wr_req;
            wr_req_d2 <= wr_req_d1;
            wr_req_d3 <= wr_req_d2;
        end
    end

    // 2. 边沿检测与控制
    wire posedge_wr_req = wr_req_d2 && !wr_req_d3;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            synced_wr_start <= 1'b0;
            synced_wr_addr  <= 32'd0;
            synced_wr_data  <= 256'd0;
        end else begin
            if (posedge_wr_req) begin
                synced_wr_start <= 1'b1;
                synced_wr_addr  <= async_wr_addr;
                synced_wr_data  <= async_wr_data;
            end else begin
                synced_wr_start <= 1'b0;
            end
        end
    end

    // 3. ACK 生成
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            async_wr_ack <= 1'b0;
        end else begin
            if (axi_wr_done) begin
                async_wr_ack <= 1'b1;
            end else if (!wr_req_d2) begin
                async_wr_ack <= 1'b0; 
            end
        end
    end

    // =========================================================================
    // 读通道逻辑 (新增)
    // =========================================================================

    // 1. 读请求信号同步 (打两拍消除亚稳态)
    reg rd_req_d1, rd_req_d2, rd_req_d3;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_req_d1 <= 1'b0;
            rd_req_d2 <= 1'b0;
            rd_req_d3 <= 1'b0;
        end else begin
            rd_req_d1 <= async_rd_req;
            rd_req_d2 <= rd_req_d1; // 同步后的信号
            rd_req_d3 <= rd_req_d2; // 用于边沿检测
        end
    end

    // 2. 读请求边沿检测与地址锁存
    wire posedge_rd_req = rd_req_d2 && !rd_req_d3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            synced_rd_start <= 1'b0;
            synced_rd_addr  <= 32'd0;
        end else begin
            if (posedge_rd_req) begin
                synced_rd_start <= 1'b1;
                // 锁存异步侧传来的地址
                synced_rd_addr  <= async_rd_addr;
            end else begin
                synced_rd_start <= 1'b0;
            end
        end
    end

    // 3. 读数据锁存与 ACK 生成
    // 逻辑：当 AXI 完成读操作时，锁存数据并拉高 ACK。
    // 数据会一直保持稳定，直到 ACK 被拉低（即直到异步侧撤销请求）。
    (*keep="yes"*)reg[255:0] async_rd_data_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            async_rd_ack  <= 1'b0;
            async_rd_data_reg <= 256'd0;
        end else begin
            if (axi_rd_done) begin
                async_rd_ack  <= 1'b1;
                async_rd_data_reg <= axi_rd_data; // 关键：在此刻锁存从 AXI 读回的数据
            end else if (!rd_req_d2) begin
                // 当异步请求撤销时，撤销 ACK
                async_rd_ack  <= 1'b0;
                // async_rd_data 保持不变即可，等待下一次更新
            end
        end
    end

    assign async_rd_data = async_rd_data_reg;

endmodule