module status_top (


    // Upstream 4-channel inputs (128-bit each) + valids
    input  [127:0]      info_in_id0,
    input  [127:0]      info_in_id1,
    input  [127:0]      info_in_id2,
    input  [127:0]      info_in_id3,
    input               valid_in_id0,
    input               valid_in_id1,
    input               valid_in_id2,
    input               valid_in_id3,

    // Clear counter request to module2
    input               clear_counter,

    // Module1 outputs exposed for test/observation
    output [31:0]       out_free_mem_id0,
    output [31:0]       out_pending_tasks_id0,
    output              out_info1_valid_id0,
    output [31:0]       out_free_mem_id1,
    output [31:0]       out_pending_tasks_id1,
    output              out_info1_valid_id1,
    output [31:0]       out_free_mem_id2,
    output [31:0]       out_pending_tasks_id2,
    output              out_info1_valid_id2,
    output [31:0]       out_free_mem_id3,
    output [31:0]       out_pending_tasks_id3,
    output              out_info1_valid_id3,

    // Status signals from module2
    output              upstream_busy,
    output              threshold_reached,            // single unified pulse

    // Multi-channel controller interfaces (data)
    output              ctrl1_wr_start_id0,
    output [31:0]       ctrl1_wr_addr_id0,
    output [63:0]       ctrl1_wr_data_id0,
    input               ctrl1_wr_done_id0,

    output              ctrl1_wr_start_id1,
    output [31:0]       ctrl1_wr_addr_id1,
    output [63:0]       ctrl1_wr_data_id1,
    input               ctrl1_wr_done_id1,

    output              ctrl1_wr_start_id2,
    output [31:0]       ctrl1_wr_addr_id2,
    output [63:0]       ctrl1_wr_data_id2,
    input               ctrl1_wr_done_id2,

    output              ctrl1_wr_start_id3,
    output [31:0]       ctrl1_wr_addr_id3,
    output [63:0]       ctrl1_wr_data_id3,
    input               ctrl1_wr_done_id3,

    // Multi-channel controller interfaces (count)
    output              ctrl2_wr_start_id0,
    output [31:0]       ctrl2_wr_addr_id0,
    output [31:0]       ctrl2_wr_data_id0,
    input               ctrl2_wr_done_id0,

    output              ctrl2_wr_start_id1,
    output [31:0]       ctrl2_wr_addr_id1,
    output [31:0]       ctrl2_wr_data_id1,
    input               ctrl2_wr_done_id1,

    output              ctrl2_wr_start_id2,
    output [31:0]       ctrl2_wr_addr_id2,
    output [31:0]       ctrl2_wr_data_id2,
    input               ctrl2_wr_done_id2,

    output              ctrl2_wr_start_id3,
    output [31:0]       ctrl2_wr_addr_id3,
    output [31:0]       ctrl2_wr_data_id3,
    input               ctrl2_wr_done_id3,

    input               clk,
    input               rst_n
);

    // Wires between splitter and modules
    wire [63:0] info_type1_id0;
    wire [63:0] info_type1_id1;
    wire [63:0] info_type1_id2;
    wire [63:0] info_type1_id3;

    wire [63:0] info_type2_id0;
    wire [63:0] info_type2_id1;
    wire [63:0] info_type2_id2;
    wire [63:0] info_type2_id3;

    wire        valid_type1_id0;
    wire        valid_type1_id1;
    wire        valid_type1_id2;
    wire        valid_type1_id3;

    wire        valid_type2_id0;
    wire        valid_type2_id1;
    wire        valid_type2_id2;
    wire        valid_type2_id3;

    // Splitter: route high 64 bits to module1, low 64 bits to module2
    status_splitter splitter_inst (
        .info_in_id0(info_in_id0),
        .info_in_id1(info_in_id1),
        .info_in_id2(info_in_id2),
        .info_in_id3(info_in_id3),
        .valid_in_id0(valid_in_id0),
        .valid_in_id1(valid_in_id1),
        .valid_in_id2(valid_in_id2),
        .valid_in_id3(valid_in_id3),
        .upstream_busy(upstream_busy),
        .info_type1_id0(info_type1_id0),
        .info_type1_id1(info_type1_id1),
        .info_type1_id2(info_type1_id2),
        .info_type1_id3(info_type1_id3),
        .valid_type1_id0(valid_type1_id0),
        .valid_type1_id1(valid_type1_id1),
        .valid_type1_id2(valid_type1_id2),
        .valid_type1_id3(valid_type1_id3),
        .info_type2_id0(info_type2_id0),
        .info_type2_id1(info_type2_id1),
        .info_type2_id2(info_type2_id2),
        .info_type2_id3(info_type2_id3),
        .valid_type2_id0(valid_type2_id0),
        .valid_type2_id1(valid_type2_id1),
        .valid_type2_id2(valid_type2_id2),
        .valid_type2_id3(valid_type2_id3),
        .module2_busy(upstream_busy)
    );

    // Module1: direct outputs
    status_detect_module1 module1_inst (
        .info_valid_id0(valid_type1_id0),
        .info_valid_id1(valid_type1_id1),
        .info_valid_id2(valid_type1_id2),
        .info_valid_id3(valid_type1_id3),
        .sub_board_info_type1_id0(info_type1_id0),
        .sub_board_info_type1_id1(info_type1_id1),
        .sub_board_info_type1_id2(info_type1_id2),
        .sub_board_info_type1_id3(info_type1_id3),
        .out_free_mem_id0(out_free_mem_id0),
        .out_pending_tasks_id0(out_pending_tasks_id0),
        .out_info1_valid_id0(out_info1_valid_id0),
        .out_free_mem_id1(out_free_mem_id1),
        .out_pending_tasks_id1(out_pending_tasks_id1),
        .out_info1_valid_id1(out_info1_valid_id1),
        .out_free_mem_id2(out_free_mem_id2),
        .out_pending_tasks_id2(out_pending_tasks_id2),
        .out_info1_valid_id2(out_info1_valid_id2),
        .out_free_mem_id3(out_free_mem_id3),
        .out_pending_tasks_id3(out_pending_tasks_id3),
        .out_info1_valid_id3(out_info1_valid_id3),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Module2: BRAM write via external controllers
    status_detect_module2 module2_inst (
        .sub_board_info_type2_id0(info_type2_id0),
        .sub_board_info_type2_id1(info_type2_id1),
        .sub_board_info_type2_id2(info_type2_id2),
        .sub_board_info_type2_id3(info_type2_id3),
        .info_valid_id0(valid_type2_id0),
        .info_valid_id1(valid_type2_id1),
        .info_valid_id2(valid_type2_id2),
        .info_valid_id3(valid_type2_id3),
        .clear_counter(clear_counter),
        .busy(upstream_busy),
        .threshold_reached(threshold_reached),
        .ctrl1_wr_start_id0(ctrl1_wr_start_id0), .ctrl1_wr_addr_id0(ctrl1_wr_addr_id0), .ctrl1_wr_data_id0(ctrl1_wr_data_id0), .ctrl1_wr_done_id0(ctrl1_wr_done_id0),
        .ctrl1_wr_start_id1(ctrl1_wr_start_id1), .ctrl1_wr_addr_id1(ctrl1_wr_addr_id1), .ctrl1_wr_data_id1(ctrl1_wr_data_id1), .ctrl1_wr_done_id1(ctrl1_wr_done_id1),
        .ctrl1_wr_start_id2(ctrl1_wr_start_id2), .ctrl1_wr_addr_id2(ctrl1_wr_addr_id2), .ctrl1_wr_data_id2(ctrl1_wr_data_id2), .ctrl1_wr_done_id2(ctrl1_wr_done_id2),
        .ctrl1_wr_start_id3(ctrl1_wr_start_id3), .ctrl1_wr_addr_id3(ctrl1_wr_addr_id3), .ctrl1_wr_data_id3(ctrl1_wr_data_id3), .ctrl1_wr_done_id3(ctrl1_wr_done_id3),
        .ctrl2_wr_start_id0(ctrl2_wr_start_id0), .ctrl2_wr_addr_id0(ctrl2_wr_addr_id0), .ctrl2_wr_data_id0(ctrl2_wr_data_id0), .ctrl2_wr_done_id0(ctrl2_wr_done_id0),
        .ctrl2_wr_start_id1(ctrl2_wr_start_id1), .ctrl2_wr_addr_id1(ctrl2_wr_addr_id1), .ctrl2_wr_data_id1(ctrl2_wr_data_id1), .ctrl2_wr_done_id1(ctrl2_wr_done_id1),
        .ctrl2_wr_start_id2(ctrl2_wr_start_id2), .ctrl2_wr_addr_id2(ctrl2_wr_addr_id2), .ctrl2_wr_data_id2(ctrl2_wr_data_id2), .ctrl2_wr_done_id2(ctrl2_wr_done_id2),
        .ctrl2_wr_start_id3(ctrl2_wr_start_id3), .ctrl2_wr_addr_id3(ctrl2_wr_addr_id3), .ctrl2_wr_data_id3(ctrl2_wr_data_id3), .ctrl2_wr_done_id3(ctrl2_wr_done_id3),
        .clk(clk),
        .rst_n(rst_n)
    );

    // threshold_reached already provided by module2 as single pulse

endmodule
