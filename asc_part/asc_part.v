module asc_part(

    input i_driveFMMU,
    output o_free2MMU,
    output o_drive2MMU,
    input i_freeFromMMU,
    input wen,
    input [32-1:0] addr,
    input [256-1:0] wdata,
    output [256-1:0] rdata,
    input rst,


    //=================================
    input axi_wr_done,
    output synced_wr_start,
    output [31:0] synced_wr_addr,
    output [255:0] synced_wr_data,

    input axi_rd_done,
    output synced_rd_start,
    output [31:0] synced_rd_addr,
    input [255:0] axi_rd_data,


    //================================

    input ACLK,
    input ARESETN
);



wire        async_wr_req;
wire [31:0] async_wr_addr;
wire [255:0] async_wr_data;
wire        async_wr_ack;
wire        async_rd_req;
wire [31:0] async_rd_addr;
wire [255:0] async_rd_data;
wire        async_rd_ack;

asc_top#(
    .PACKET_SIZE   ( 256 ),
    .ADDR_WIDTH    ( 32 )
)u_asc_top(
    .o_RD_START    ( async_rd_req    ),
    .o_WR_START    ( async_wr_req    ),
    .WR_ADDR       ( async_wr_addr       ),
    .WR_DATA       ( async_wr_data       ),
    .RD_ADDR       ( async_rd_addr       ),
    .RD_DATA       ( async_rd_data       ),
    .WR_DONE       ( async_wr_ack       ),
    .RD_DONE       ( async_rd_ack       ),
    .i_driveFMMU   ( i_driveFMMU   ),
    .o_free2MMU    ( o_free2MMU    ),
    .o_drive2MMU   ( o_drive2MMU   ),
    .i_freeFromMMU ( i_freeFromMMU ),
    .wen           ( wen           ),
    .addr          ( addr          ),
    .wdata         ( wdata         ),
    .rdata         ( rdata         ),
    .rst           ( rst           )
);


async_bridge u_async_bridge(
    .clk             ( ACLK             ),
    .rst_n           ( ARESETN           ),
    .async_wr_req    ( async_wr_req    ),
    .async_wr_addr   ( async_wr_addr   ),
    .async_wr_data   ( async_wr_data   ),
    .async_wr_ack    ( async_wr_ack    ),
    .synced_wr_start ( synced_wr_start ),
    .synced_wr_addr  ( synced_wr_addr  ),
    .synced_wr_data  ( synced_wr_data  ),
    .axi_wr_done     ( axi_wr_done     ),
    .async_rd_req    ( async_rd_req    ),
    .async_rd_addr   ( async_rd_addr   ),
    .async_rd_data   ( async_rd_data   ),
    .async_rd_ack    ( async_rd_ack    ),
    .synced_rd_start ( synced_rd_start ),
    .synced_rd_addr  ( synced_rd_addr  ),
    .axi_rd_done     ( axi_rd_done     ),
    .axi_rd_data     ( axi_rd_data     )
);



endmodule