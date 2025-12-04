`timescale 1 ns / 1 ps


module status_detect_top (

    input clear_sig,

    input [127:0] info_in_id0,
    input valid_in_id0,
    output[31:0] out_free_mem_id0,
    output[31:0] out_pending_tasks_id0,
    output out_info1_valid_id0,

    input [127:0] info_in_id1,
    input valid_in_id1,
    output[31:0] out_free_mem_id1,
    output[31:0] out_pending_tasks_id1,
    output out_info1_valid_id1,

    input [127:0] info_in_id2,
    input valid_in_id2,
    output[31:0] out_free_mem_id2,
    output[31:0] out_pending_tasks_id2,
    output out_info1_valid_id2,
    

    input [127:0] info_in_id3,
    input valid_in_id3,
    output[31:0] out_free_mem_id3,
    output[31:0] out_pending_tasks_id3,
    output out_info1_valid_id3,

    output        upstream_busy,
    output        threshold_reached,

    input ACLK,
    input ARESETN
);


wire ctrl1_wr_start_id0;
wire [31:0] ctrl1_wr_addr_id0;
wire [63:0] ctrl1_wr_data_id0;
wire ctrl1_wr_done_id0;
wire ctrl2_wr_start_id0;
wire [31:0] ctrl2_wr_addr_id0;
wire [31:0] ctrl2_wr_data_id0;
wire ctrl2_wr_done_id0;

wire ctrl1_wr_start_id1;
wire [31:0] ctrl1_wr_addr_id1;
wire [63:0] ctrl1_wr_data_id1;
wire ctrl1_wr_done_id1;
wire ctrl2_wr_start_id1;
wire [31:0] ctrl2_wr_addr_id1;
wire [31:0] ctrl2_wr_data_id1;
wire ctrl2_wr_done_id1;


wire ctrl1_wr_start_id2;
wire [31:0] ctrl1_wr_addr_id2;
wire [63:0] ctrl1_wr_data_id2;
wire ctrl1_wr_done_id2;
wire ctrl2_wr_start_id2;
wire [31:0] ctrl2_wr_addr_id2;
wire [31:0] ctrl2_wr_data_id2;
wire ctrl2_wr_done_id2;

wire ctrl1_wr_start_id3;
wire [31:0] ctrl1_wr_addr_id3;
wire [63:0] ctrl1_wr_data_id3;
wire ctrl1_wr_done_id3;
wire ctrl2_wr_start_id3;
wire [31:0] ctrl2_wr_addr_id3;
wire [31:0] ctrl2_wr_data_id3;
wire ctrl2_wr_done_id3;

(*dont_touch = "true"*)status_top u_status_top(
    .info_in_id0           (  info_in_id0          ),
    .info_in_id1           (  info_in_id1          ),
    .info_in_id2           (  info_in_id2          ),
    .info_in_id3           (  info_in_id3          ),
    .valid_in_id0          (  valid_in_id0         ),
    .valid_in_id1          (  valid_in_id1         ),
    .valid_in_id2          (  valid_in_id2         ),
    .valid_in_id3          (  valid_in_id3         ),
    .clear_counter         (  clear_sig        ),
    .out_free_mem_id0      (  out_free_mem_id0       ),
    .out_pending_tasks_id0 (  out_pending_tasks_id0  ),
    .out_info1_valid_id0   (  out_info1_valid_id0    ),
    .out_free_mem_id1      (  out_free_mem_id1       ),
    .out_pending_tasks_id1 (  out_pending_tasks_id1  ),
    .out_info1_valid_id1   (  out_info1_valid_id1    ),
    .out_free_mem_id2      (  out_free_mem_id2       ),
    .out_pending_tasks_id2 (  out_pending_tasks_id2  ),
    .out_info1_valid_id2   (  out_info1_valid_id2    ),
    .out_free_mem_id3      (  out_free_mem_id3     ),
    .out_pending_tasks_id3 (  out_pending_tasks_id3  ),
    .out_info1_valid_id3   (  out_info1_valid_id3    ),
    .upstream_busy         (  upstream_busy       ),
    .threshold_reached     (  threshold_reached      ),
    .ctrl1_wr_start_id0    (  ctrl1_wr_start_id0   ),
    .ctrl1_wr_addr_id0     (  ctrl1_wr_addr_id0    ),
    .ctrl1_wr_data_id0     (  ctrl1_wr_data_id0    ),
    .ctrl1_wr_done_id0     (  ctrl1_wr_done_id0    ),
    .ctrl1_wr_start_id1    (  ctrl1_wr_start_id1   ),
    .ctrl1_wr_addr_id1     (  ctrl1_wr_addr_id1    ),
    .ctrl1_wr_data_id1     (  ctrl1_wr_data_id1    ),
    .ctrl1_wr_done_id1     (  ctrl1_wr_done_id1    ),
    .ctrl1_wr_start_id2    (  ctrl1_wr_start_id2   ),
    .ctrl1_wr_addr_id2     (  ctrl1_wr_addr_id2    ),
    .ctrl1_wr_data_id2     (  ctrl1_wr_data_id2    ),
    .ctrl1_wr_done_id2     (  ctrl1_wr_done_id2    ),
    .ctrl1_wr_start_id3    (  ctrl1_wr_start_id3   ),
    .ctrl1_wr_addr_id3     (  ctrl1_wr_addr_id3    ),
    .ctrl1_wr_data_id3     (  ctrl1_wr_data_id3    ),
    .ctrl1_wr_done_id3     (  ctrl1_wr_done_id3    ),
    .ctrl2_wr_start_id0    ( ctrl2_wr_start_id0    ),
    .ctrl2_wr_addr_id0     ( ctrl2_wr_addr_id0     ),
    .ctrl2_wr_data_id0     ( ctrl2_wr_data_id0     ),
    .ctrl2_wr_done_id0     ( ctrl2_wr_done_id0     ),
    .ctrl2_wr_start_id1    ( ctrl2_wr_start_id1    ),
    .ctrl2_wr_addr_id1     ( ctrl2_wr_addr_id1     ),
    .ctrl2_wr_data_id1     ( ctrl2_wr_data_id1     ),
    .ctrl2_wr_done_id1     ( ctrl2_wr_done_id1     ),
    .ctrl2_wr_start_id2    ( ctrl2_wr_start_id2    ),
    .ctrl2_wr_addr_id2     ( ctrl2_wr_addr_id2     ),
    .ctrl2_wr_data_id2     ( ctrl2_wr_data_id2     ),
    .ctrl2_wr_done_id2     ( ctrl2_wr_done_id2     ),
    .ctrl2_wr_start_id3    ( ctrl2_wr_start_id3    ),
    .ctrl2_wr_addr_id3     ( ctrl2_wr_addr_id3     ),
    .ctrl2_wr_data_id3     ( ctrl2_wr_data_id3     ),
    .ctrl2_wr_done_id3     ( ctrl2_wr_done_id3     ),
    .clk                   ( ACLK                   ),
    .rst_n                 ( ARESETN                )
);

wire [255:0] WR_DATA_IN_0;
(*keep = "yes"*)wire[255:0]  WR_DATA_IN_1, WR_DATA_IN_2, WR_DATA_IN_3;
(*keep = "yes"*)wire[255:0] WR_DATA_IN_4, WR_DATA_IN_5, WR_DATA_IN_6, WR_DATA_IN_7;

assign WR_DATA_IN_0 = {196'b0,ctrl1_wr_data_id0};
assign WR_DATA_IN_1 = {196'b0,ctrl1_wr_data_id1};
assign WR_DATA_IN_2 = {196'b0,ctrl1_wr_data_id2};
assign WR_DATA_IN_3 = {196'b0,ctrl1_wr_data_id3};
assign WR_DATA_IN_4 = {224'b0,ctrl2_wr_data_id0};
assign WR_DATA_IN_5 = {224'b0,ctrl2_wr_data_id1};
assign WR_DATA_IN_6 = {224'b0,ctrl2_wr_data_id2};
assign WR_DATA_IN_7 = {224'b0,ctrl2_wr_data_id3};

(*dont_touch = "true"*)bd2_wrapper u_bd2_wrapper(
    .ACLK_0          ( ACLK          ),
    .ARESETN_0       ( ARESETN       ),
    .WR_ADRS_0       ( ctrl1_wr_addr_id0       ),
    .WR_ADRS_1       ( ctrl1_wr_addr_id1       ),
    .WR_ADRS_2       ( ctrl1_wr_addr_id2       ),
    .WR_ADRS_3       ( ctrl1_wr_addr_id3       ),
    .WR_ADRS_4       ( ctrl2_wr_addr_id0       ),
    .WR_ADRS_5       ( ctrl2_wr_addr_id1       ),
    .WR_ADRS_6       ( ctrl2_wr_addr_id2       ),
    .WR_ADRS_7       ( ctrl2_wr_addr_id3       ),
    .WR_DATA_IN_0    ( WR_DATA_IN_0    ),
    .WR_DATA_IN_1    ( WR_DATA_IN_1    ),
    .WR_DATA_IN_2    ( WR_DATA_IN_2    ),
    .WR_DATA_IN_3    ( WR_DATA_IN_3    ),
    .WR_DATA_IN_4    ( WR_DATA_IN_4    ),
    .WR_DATA_IN_5    ( WR_DATA_IN_5    ),
    .WR_DATA_IN_6    ( WR_DATA_IN_6    ),
    .WR_DATA_IN_7    ( WR_DATA_IN_7    ),
    .WR_DONE_0       ( ctrl1_wr_done_id0       ),
    .WR_DONE_1       ( ctrl1_wr_done_id1       ),
    .WR_DONE_2       ( ctrl1_wr_done_id2       ),
    .WR_DONE_3       ( ctrl1_wr_done_id3       ),
    .WR_DONE_4       ( ctrl2_wr_done_id0       ),
    .WR_DONE_5       ( ctrl2_wr_done_id1       ),
    .WR_DONE_6       ( ctrl2_wr_done_id2       ),
    .WR_DONE_7       ( ctrl2_wr_done_id3       ),
    .WR_START_0      ( ctrl1_wr_start_id0      ),
    .WR_START_1      ( ctrl1_wr_start_id1      ),
    .WR_START_2      ( ctrl1_wr_start_id2      ),
    .WR_START_3      ( ctrl1_wr_start_id3      ),
    .WR_START_4      ( ctrl2_wr_start_id0      ),
    .WR_START_5      ( ctrl2_wr_start_id1      ),
    .WR_START_6      ( ctrl2_wr_start_id2      ),
    .WR_START_7      ( ctrl2_wr_start_id3      )


    //     .RD_ADRS_0       (        ),
    // .RD_ADRS_1       (        ),
    // .RD_ADRS_2       (        ),
    // .RD_ADRS_3       (        ),
    // .RD_ADRS_4       (        ),
    // .RD_ADRS_5       (        ),
    // .RD_ADRS_6       (        ),
    // .RD_ADRS_7       (        ),
    // .RD_DATA_0       (        ),
    // .RD_DATA_1       (        ),
    // .RD_DATA_2       (        ),
    // .RD_DATA_3       (        ),
    // .RD_DATA_4       (        ),
    // .RD_DATA_5       (        ),
    // .RD_DATA_6       (        ),
    // .RD_DATA_7       (        ),
    // .RD_DATA_VALID_0 (  ),
    // .RD_DATA_VALID_1 (  ),
    // .RD_DATA_VALID_2 (  ),
    // .RD_DATA_VALID_3 (  ),
    // .RD_DATA_VALID_4 (  ),
    // .RD_DATA_VALID_5 (  ),
    // .RD_DATA_VALID_6 (  ),
    // .RD_DATA_VALID_7 (  ),
    // .RD_DONE_0       (        ),
    // .RD_DONE_1       (        ),
    // .RD_DONE_3       (        ),
    // .RD_DONE_4       (        ),
    // .RD_DONE_5       (        ),
    // .RD_DONE_6       (        ),
    // .RD_DONE_7       (        ),
    // .RD_START_0      (       ),
    // .RD_START_1      (       ),
    // .RD_START_2      (      ),
    // .RD_START_3      (       ),
    // .RD_START_4      (       ),
    // .RD_START_5      (       ),
    // .RD_START_6      (       ),
    // .RD_START_7      (       ),
);



endmodule