`timescale 1ns / 1ps

module tb_asc_part;

// 参数定义
localparam PACKET_SIZE = 256;
localparam ADDR_WIDTH  = 32;
localparam ACLK_PERIOD = 10;  // 10ns时钟周期

// 信号声明
reg         i_driveFMMU;
reg         i_freeFromMMU;
reg         wen;
reg  [ADDR_WIDTH-1:0] addr;
reg  [PACKET_SIZE-1:0] wdata;
reg         rst;
reg         axi_wr_done;
reg         axi_rd_done;
reg  [PACKET_SIZE-1:0] axi_rd_data;
reg         ACLK;
reg         ARESETN;

wire [PACKET_SIZE-1:0] rdata;
wire        synced_wr_start;
wire [ADDR_WIDTH-1:0] synced_wr_addr;
wire [PACKET_SIZE-1:0] synced_wr_data;
wire        synced_rd_start;
wire [ADDR_WIDTH-1:0] synced_rd_addr;
wire        o_free2MMU;
wire        o_drive2MMU;

// 模块实例化
asc_part u_asc_part(
    .i_driveFMMU   (i_driveFMMU),
    .o_free2MMU    (o_free2MMU),
    .o_drive2MMU   (o_drive2MMU),
    .i_freeFromMMU (i_freeFromMMU),
    .wen           (wen),
    .addr          (addr),
    .wdata         (wdata),
    .rdata         (rdata),
    .rst           (rst),
    .axi_wr_done   (axi_wr_done),
    .synced_wr_start(synced_wr_start),
    .synced_wr_addr(synced_wr_addr),
    .synced_wr_data(synced_wr_data),
    .axi_rd_done   (axi_rd_done),
    .synced_rd_start(synced_rd_start),
    .synced_rd_addr(synced_rd_addr),
    .axi_rd_data   (axi_rd_data),
    .ACLK          (ACLK),
    .ARESETN       (ARESETN)
);

// 时钟生成
initial begin
    ACLK = 1'b0;
    forever #2.5 ACLK = ~ACLK;
end

//测试流程
initial begin
    // 1. 信号初始化
    i_driveFMMU   = 1'b0;
    i_freeFromMMU = 1'b0;
    wen           = 1'b0;
    addr          = 32'd0;
    wdata         = 256'd0;
    rst           = 1'b1;
    axi_wr_done   = 1'b0;
    axi_rd_done   = 1'b0;
    axi_rd_data   = 256'd0;
    ARESETN       = 1'b0;
  #100  ;
    // 2. 复位
    rst=0;
   #1000;
    rst=1;
    ARESETN = 1'b1;
    // 3. 写操作测试
    

    wen         = 1'b1;
    addr        = 32'hC0000000;
    wdata       = 256'hDEAD_BEEF_CAFE_BABE_1122_3344_5566_7788_99AA_BBCC_DDEE_FF00_1234_5678_9ABC_DEF0;
    #5;
    i_driveFMMU = 1'b1;
    #10;
    i_driveFMMU = 1'b0;
    wen = 1'b0;
   wait(synced_wr_start==1);

    #(ACLK_PERIOD);
    axi_wr_done = 1'b1;
    #(ACLK_PERIOD);
    axi_wr_done = 1'b0;

    #(ACLK_PERIOD * 2);

    #1000;
    // 4. 读操作测试
    $display("=== 读操作测试 ===");
  
    wen         = 1'b0;
    addr        = 32'hC0000000;
    axi_rd_data = 256'h876543210FEDCBA9;
    #5;
      i_driveFMMU = 1'b1;
    #5;
        i_driveFMMU = 1'b0;    

     wait(synced_rd_start==1);

    #(ACLK_PERIOD);
    axi_rd_done = 1'b1;
    #(ACLK_PERIOD);
    axi_rd_done = 1'b0;
    #1000;


   $finish;
end

always @(posedge o_drive2MMU) begin
    i_freeFromMMU = 1'b1;
    #5;
    i_freeFromMMU = 1'b0;
end


endmodule