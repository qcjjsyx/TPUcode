module top(
    input i_driveFMMU,
    output o_free2MMU,
    output o_drive2MMU,
    input i_freeFromMMU,
    input wen,
    input [32-1:0] addr,
    input [256-1:0] wdata,
    output [256-1:0] rdata,
    input rst,

    input ACLK,
    input ARESETN
);


wire axi_wr_done, axi_rd_done;
wire wr_start, rd_start;
wire [31:0] wr_addr, rd_addr;
wire [255:0] wr_data, rd_data;
asc_part u_asc_part(
    .i_driveFMMU     ( i_driveFMMU     ),
    .o_free2MMU      ( o_free2MMU      ),
    .o_drive2MMU     ( o_drive2MMU     ),
    .i_freeFromMMU   ( i_freeFromMMU   ),
    .wen             ( wen             ),
    .addr            ( addr            ),
    .wdata           ( wdata           ),
    .rdata           ( rdata           ),
    .rst             ( rst             ),
    .axi_wr_done     ( axi_wr_done     ),
    .synced_wr_start ( wr_start ),
    .synced_wr_addr  ( wr_addr  ),
    .synced_wr_data  ( wr_data  ),
    .axi_rd_done     ( axi_rd_done      ),
    .synced_rd_start ( rd_start  ),
    .synced_rd_addr  ( rd_addr   ),
    .axi_rd_data     ( rd_data   ),
    .ACLK            ( ACLK            ),
    .ARESETN         ( ARESETN         )
);


PCIe_wrapper u_PCIe_wrapper(
    .ACLK_0          ( ACLK          ),
    .ARESETN_0       ( ARESETN       ),
    .RD_ADRS_0       ( rd_addr       ),
    .RD_DATA_0       ( rd_data       ),
    .RD_DATA_VALID_0 (  ),
    .RD_DONE_0       ( axi_rd_done       ),
    .RD_START_0      ( rd_start      ),
    .WR_ADRS_0       ( wr_addr        ),
    .WR_DATA_IN_0    ( wr_data     ),
    .WR_DONE_0       ( axi_wr_done       ),
    .WR_START_0      ( wr_start      )
);





endmodule