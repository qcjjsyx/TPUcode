`timescale 1ns / 1ps

module tb_top (
);
    
reg ACLK;
reg ARESETN;

reg         i_driveFMMU;
wire        o_free2MMU;
wire        o_drive2MMU;
reg         i_freeFromMMU;
reg         wen;
reg [31:0]  addr;
reg [255:0]  wdata;
wire [255:0] rdata;
reg         rst;


initial begin
    ACLK = 1'b0;
    forever #2.5 ACLK = ~ACLK;
end

initial begin
    rst = 1'b1;
    ARESETN = 1'b0;
    #100;
    rst = 1'b0;
    #1000;
    ARESETN = 1'b1;
    rst = 1'b1;
end

initial begin
    // Initialize signals
    i_driveFMMU = 1'b0;
    i_freeFromMMU = 1'b0;
    wen = 1'b0;
    addr = 32'd0;
    wdata = 256'd0;

    wait(ARESETN == 1'b1 && rst == 1'b1);
    // write test
    wen         = 1'b1;
    addr        = 32'hC0000000;
    wdata       = 256'hDEAD_BEEF_CAFE_BABE_1122_3344_5566_7788_99AA_BBCC_DDEE_FF00_1234_5678_9ABC_DEF0;
    #5;
    i_driveFMMU = 1'b1;
    #5
    i_driveFMMU = 1'b0;
    #5;
    wen = 1'b0;
    addr = 32'd0;

    #1000;
    addr = 32'hC0000000;
    wen = 1'b0;
    #5;
    i_driveFMMU = 1'b1;
    #5;
    i_driveFMMU = 1'b0;

    #5000;
    $finish;
end

always @(posedge o_drive2MMU) begin
    i_freeFromMMU <= 1'b1;
    #5;
    i_freeFromMMU <= 1'b0;
end

top u_top(
    .i_driveFMMU   ( i_driveFMMU   ),
    .o_free2MMU    ( o_free2MMU    ),
    .o_drive2MMU   ( o_drive2MMU   ),
    .i_freeFromMMU ( i_freeFromMMU ),
    .wen           ( wen           ),
    .addr          ( addr          ),
    .wdata         ( wdata         ),
    .rdata         ( rdata         ),
    .rst           ( rst           ),
    .ACLK          ( ACLK          ),
    .ARESETN       ( ARESETN       )
);

endmodule