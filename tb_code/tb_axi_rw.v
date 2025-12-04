`timescale 1ns / 1ps

module tb_axi_rw (

);
reg ACLK_0;
reg ARESETN_0;
reg [31:0] RD_ADRS_0;
wire [31:0] RD_DATA_0;
reg RD_START_0;
wire RD_DATA_VALID_0;
wire RD_DONE_0;
reg [31:0] WR_ADRS_0;
reg [255:0] WR_DATA_IN_0;
wire WR_DONE_0;
reg WR_START_0;
initial begin
    ACLK_0 = 1'b0;
    forever #2.5 ACLK_0 = ~ACLK_0;

end

initial begin
    ARESETN_0 = 1'b0;
    #1000;
    ARESETN_0 = 1'b1;
end
initial begin
    RD_ADRS_0 = 32'h0000_0000;
    RD_START_0 = 1'b0;
    WR_ADRS_0 = 32'h0000_0000;
    WR_DATA_IN_0 = 256'h0;
    WR_START_0 = 1'b0;

    wait(ARESETN_0 == 1'b1);
    #100;
    @(negedge ACLK_0);
    // write test
    WR_ADRS_0 = 32'hC000_0000;
    WR_DATA_IN_0 = 256'hDEAD_BEEF_CAFE_BABE_1122_3344_5566_7788_99AA_BBCC_DDEE_FF00_1234_5678_9ABC_DEF0;
    WR_START_0 = 1'b1;
    #5;
    WR_START_0 = 1'b0;
    wait(WR_DONE_0 == 1'b1);
    #1000;

    // read test
    @(negedge ACLK_0);
    RD_ADRS_0 = 32'hC000_0000;
    RD_START_0 = 1'b1;
    #5;
    RD_START_0 = 1'b0;
    wait(RD_DONE_0 == 1'b1);
    #1000;
    
end


PCIe_wrapper u_PCIe_wrapper(
    .ACLK_0          ( ACLK_0          ),
    .ARESETN_0       ( ARESETN_0       ),
    .RD_ADRS_0       ( RD_ADRS_0       ),
    .RD_DATA_0       ( RD_DATA_0       ),
    .RD_DATA_VALID_0 ( RD_DATA_VALID_0 ),
    .RD_DONE_0       ( RD_DONE_0       ),
    .RD_START_0      ( RD_START_0      ),
    .WR_ADRS_0       ( WR_ADRS_0       ),
    .WR_DATA_IN_0    ( WR_DATA_IN_0    ),
    .WR_DONE_0       ( WR_DONE_0       ),
    .WR_START_0      ( WR_START_0      )
);



endmodule