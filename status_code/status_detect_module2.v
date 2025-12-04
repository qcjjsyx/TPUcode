// Multi-channel version: four data write channels and four count write channels
// Unified threshold: pulse when sum of all four task counters reaches/exceeds THRESHOLD.
module status_detect_module2 (
    input [63:0] sub_board_info_type2_id0,
    input [63:0] sub_board_info_type2_id1,
    input [63:0] sub_board_info_type2_id2,
    input [63:0] sub_board_info_type2_id3,

    input        info_valid_id0,
    input        info_valid_id1,
    input        info_valid_id2,
    input        info_valid_id3,

    input        clear_counter,

    // Busy if any channel active
    output       busy,

    // Single unified threshold pulse (sum of all four counters >= THRESHOLD)
    output        threshold_reached,

    // Data write channel interfaces (channel 0..3)
    output reg          ctrl1_wr_start_id0,
    output reg [31:0]   ctrl1_wr_addr_id0,
    output reg [63:0]   ctrl1_wr_data_id0,
    input               ctrl1_wr_done_id0,

    output reg          ctrl1_wr_start_id1,
    output reg [31:0]   ctrl1_wr_addr_id1,
    output reg [63:0]   ctrl1_wr_data_id1,
    input               ctrl1_wr_done_id1,

    output reg          ctrl1_wr_start_id2,
    output reg [31:0]   ctrl1_wr_addr_id2,
    output reg [63:0]   ctrl1_wr_data_id2,
    input               ctrl1_wr_done_id2,

    output reg          ctrl1_wr_start_id3,
    output reg [31:0]   ctrl1_wr_addr_id3,
    output reg [63:0]   ctrl1_wr_data_id3,
    input               ctrl1_wr_done_id3,

    // Count write channel interfaces
    output reg          ctrl2_wr_start_id0,
    output reg [31:0]   ctrl2_wr_addr_id0,
    output reg [31:0]   ctrl2_wr_data_id0,
    input               ctrl2_wr_done_id0,

    output reg          ctrl2_wr_start_id1,
    output reg [31:0]   ctrl2_wr_addr_id1,
    output reg [31:0]   ctrl2_wr_data_id1,
    input               ctrl2_wr_done_id1,

    output reg          ctrl2_wr_start_id2,
    output reg [31:0]   ctrl2_wr_addr_id2,
    output reg [31:0]   ctrl2_wr_data_id2,
    input               ctrl2_wr_done_id2,

    output reg          ctrl2_wr_start_id3,
    output reg [31:0]   ctrl2_wr_addr_id3,
    output reg [31:0]   ctrl2_wr_data_id3,
    input               ctrl2_wr_done_id3,

    input               clk,
    input               rst_n
);

    // Parameters: base addresses for data and count regions
    parameter [31:0] DATA_BASE_ID0  = 32'hC000_0000;
    parameter [31:0] DATA_BASE_ID1  = 32'hC001_0000;
    parameter [31:0] DATA_BASE_ID2  = 32'hC002_0000;
    parameter [31:0] DATA_BASE_ID3  = 32'hC003_0000;
    parameter [31:0] COUNT_BASE_ID0 = 32'hC100_0000;
    parameter [31:0] COUNT_BASE_ID1 = 32'hC101_0000;
    parameter [31:0] COUNT_BASE_ID2 = 32'hC102_0000;
    parameter [31:0] COUNT_BASE_ID3 = 32'hC103_0000;
    parameter [31:0] THRESHOLD      = 32'd256;

    // Per-channel write pointers & counters
    reg [31:0] write_addr_ptr_id0;
    reg [31:0] write_addr_ptr_id1;
    reg [31:0] write_addr_ptr_id2;
    reg [31:0] write_addr_ptr_id3;

    (*keep="yes"*)reg [8:0] task_count_id0;
    (*keep="yes"*)reg [8:0] task_count_id1;
    (*keep="yes"*)reg [8:0] task_count_id2;
    (*keep="yes"*)reg [8:0] task_count_id3;

    // Global one-shot threshold latch
    reg threshold_sent;
    assign threshold_reached = threshold_sent;

    // Channel state machines
    localparam CH_IDLE           = 4'b0001;
    localparam CH_WAIT_DATA_DONE = 4'b0010;
    localparam CH_WAIT_CNT_DONE  = 4'b0100;
    localparam CH_UPDATE_DATA    = 4'b1000;

    reg [3:0] ch_state_id0;
    reg [3:0] ch_state_id1;
    reg [3:0] ch_state_id2;
    reg [3:0] ch_state_id3;

    // Busy if any channel not idle
    assign busy = (ch_state_id0 != CH_IDLE) || (ch_state_id1 != CH_IDLE) || (ch_state_id2 != CH_IDLE) || (ch_state_id3 != CH_IDLE);

    // Channel 0 FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ch_state_id0 <= CH_IDLE;
            write_addr_ptr_id0 <= DATA_BASE_ID0;
            task_count_id0 <= 32'd0;
            ctrl1_wr_start_id0 <= 1'b0; ctrl1_wr_addr_id0 <= DATA_BASE_ID0; ctrl1_wr_data_id0 <= 64'd0;
            ctrl2_wr_start_id0 <= 1'b0; ctrl2_wr_addr_id0 <= COUNT_BASE_ID0; ctrl2_wr_data_id0 <= 32'd0;
        end else begin
            case (ch_state_id0)
                CH_IDLE: begin
                    ctrl1_wr_start_id0 <= 1'b0; ctrl2_wr_start_id0 <= 1'b0;
                    if (clear_counter) begin
                        // clear path: write 0 to count BRAM 
                        ctrl2_wr_start_id0 <= 1'b1; ctrl2_wr_addr_id0 <= COUNT_BASE_ID0; ctrl2_wr_data_id0 <= 32'd0;
                        task_count_id0 <= 32'd0; write_addr_ptr_id0 <= DATA_BASE_ID0;
                        ch_state_id0 <= CH_WAIT_CNT_DONE;
                    end else if (info_valid_id0 && !threshold_sent) begin
                        ctrl1_wr_addr_id0 <= write_addr_ptr_id0; ctrl1_wr_data_id0 <= sub_board_info_type2_id0;ctrl1_wr_start_id0 <= 1'b1;
                        ch_state_id0 <= CH_WAIT_DATA_DONE;
                    end
                    else begin
                       ch_state_id0 <= ch_state_id0;
                    end
                end
                CH_WAIT_DATA_DONE: begin
                    ctrl1_wr_start_id0 <= 1'b1;
                    if (ctrl1_wr_done_id0) begin
                         ctrl1_wr_start_id0 <= 1'b0;
                        ch_state_id0 <= CH_UPDATE_DATA;
                    end else begin
                        ch_state_id0 <= ch_state_id0;
                    end
                end
                CH_UPDATE_DATA: begin
                    ctrl1_wr_start_id0 <= 1'b0;
                    write_addr_ptr_id0 <= write_addr_ptr_id0 + 32'd8;
                    task_count_id0 <= task_count_id0 + 1;
                    ctrl2_wr_addr_id0 <= COUNT_BASE_ID0; ctrl2_wr_data_id0 <= task_count_id0 + 1;//ctrl2_wr_start_id0 <= 1'b1;
                    ch_state_id0 <= CH_WAIT_CNT_DONE;
                end
                CH_WAIT_CNT_DONE: begin
                    ctrl2_wr_start_id0 <= 1'b1;
                    if (ctrl2_wr_done_id0) begin
                        ctrl2_wr_start_id0 <= 1'b0;
                        ch_state_id0 <= CH_IDLE;
                    end else begin
                        ch_state_id0 <= ch_state_id0;
                    end
                end
                default: ch_state_id0 <= CH_IDLE;
            endcase
        end
    end

    // Channel 1 FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ch_state_id1 <= CH_IDLE;
            write_addr_ptr_id1 <= DATA_BASE_ID1;
            task_count_id1 <= 32'd0;
            ctrl1_wr_start_id1 <= 1'b0; ctrl1_wr_addr_id1 <= DATA_BASE_ID1; ctrl1_wr_data_id1 <= 64'd0;
            ctrl2_wr_start_id1 <= 1'b0; ctrl2_wr_addr_id1 <= COUNT_BASE_ID1; ctrl2_wr_data_id1 <= 32'd0;
        end else begin
            case (ch_state_id1)
                CH_IDLE: begin
                    ctrl1_wr_start_id1 <= 1'b0; ctrl2_wr_start_id1 <= 1'b0;
                    if (clear_counter) begin
                        ctrl2_wr_start_id1 <= 1'b1; ctrl2_wr_addr_id1 <= COUNT_BASE_ID1; ctrl2_wr_data_id1 <= 32'd0;
                        task_count_id1 <= 32'd0; write_addr_ptr_id1 <= DATA_BASE_ID1;
                        ch_state_id1 <= CH_WAIT_CNT_DONE;
                    end else if (info_valid_id1 && !threshold_sent) begin
                        ctrl1_wr_addr_id1 <= write_addr_ptr_id1; ctrl1_wr_data_id1 <= sub_board_info_type2_id1;ctrl1_wr_start_id1 <= 1'b1;
                        ch_state_id1 <= CH_WAIT_DATA_DONE;
                    end else begin
                        ch_state_id1 <= ch_state_id1;
                    end
                end
                CH_WAIT_DATA_DONE: begin
                    ctrl1_wr_start_id1 <= 1'b1;
                    if (ctrl1_wr_done_id1) begin
                        ch_state_id1 <= CH_UPDATE_DATA;
                    end else begin
                        ch_state_id1 <= ch_state_id1;
                    end
                end
                CH_UPDATE_DATA: begin
                    ctrl1_wr_start_id1 <= 1'b0;
                    write_addr_ptr_id1 <= write_addr_ptr_id1 + 32'd8;
                    task_count_id1 <= task_count_id1 + 1;
                     ctrl2_wr_addr_id1 <= COUNT_BASE_ID1; ctrl2_wr_data_id1 <= task_count_id1 + 1;//ctrl2_wr_start_id1 <= 1'b1;
                    ch_state_id1 <= CH_WAIT_CNT_DONE;
                end
                CH_WAIT_CNT_DONE: begin
                    ctrl2_wr_start_id1 <= 1'b1;
                    if (ctrl2_wr_done_id1) begin
                        ctrl2_wr_start_id1 <= 1'b0;
                        ch_state_id1 <= CH_IDLE;
                    end else begin
                        ch_state_id1 <= ch_state_id1;
                    end
                end
                default: ch_state_id1 <= CH_IDLE;
            endcase
        end
    end

    // Channel 2 FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ch_state_id2 <= CH_IDLE;
            write_addr_ptr_id2 <= DATA_BASE_ID2;
            task_count_id2 <= 32'd0;
            ctrl1_wr_start_id2 <= 1'b0; ctrl1_wr_addr_id2 <= DATA_BASE_ID2; ctrl1_wr_data_id2 <= 64'd0;
            ctrl2_wr_start_id2 <= 1'b0; ctrl2_wr_addr_id2 <= COUNT_BASE_ID2; ctrl2_wr_data_id2 <= 32'd0;
        end else begin
            case (ch_state_id2)
                CH_IDLE: begin
                    ctrl1_wr_start_id2 <= 1'b0; ctrl2_wr_start_id2 <= 1'b0;
                    if (clear_counter) begin
                        ctrl2_wr_start_id2 <= 1'b1; ctrl2_wr_addr_id2 <= COUNT_BASE_ID2; ctrl2_wr_data_id2 <= 32'd0;
                        task_count_id2 <= 32'd0; write_addr_ptr_id2 <= DATA_BASE_ID2;
                        ch_state_id2 <= CH_WAIT_CNT_DONE;
                    end else if (info_valid_id2 && !threshold_sent) begin
                        ctrl1_wr_addr_id2 <= write_addr_ptr_id2; ctrl1_wr_data_id2 <= sub_board_info_type2_id2;ctrl1_wr_start_id2 <= 1'b1;
                        ch_state_id2 <= CH_WAIT_DATA_DONE;
                    end else begin
                        ch_state_id2 <= ch_state_id2;
                    end
                end
                CH_WAIT_DATA_DONE: begin
                    ctrl1_wr_start_id2 <= 1'b1;
                    if (ctrl1_wr_done_id2) begin
                        ch_state_id2 <= CH_UPDATE_DATA;
                    end else begin
                        ch_state_id2 <= ch_state_id2;
                    end
                end
                CH_UPDATE_DATA: begin
                    ctrl1_wr_start_id2 <= 1'b0;
                    write_addr_ptr_id2 <= write_addr_ptr_id2 + 32'd8;
                    task_count_id2 <= task_count_id2 + 1;
                     ctrl2_wr_addr_id2 <= COUNT_BASE_ID2; ctrl2_wr_data_id2 <= task_count_id2 + 1;//ctrl2_wr_start_id2 <= 1'b1;
                    ch_state_id2 <= CH_WAIT_CNT_DONE;
                end
                CH_WAIT_CNT_DONE: begin
                    ctrl2_wr_start_id2 <= 1'b1;
                    if (ctrl2_wr_done_id2) begin
                        ctrl2_wr_start_id2 <= 1'b0;
                        ch_state_id2 <= CH_IDLE;
                    end else begin
                        ch_state_id2 <= ch_state_id2;
                    end
                end
                default: ch_state_id2 <= CH_IDLE;
            endcase
        end
    end

    // Channel 3 FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ch_state_id3 <= CH_IDLE;
            write_addr_ptr_id3 <= DATA_BASE_ID3;
            task_count_id3 <= 32'd0;
            ctrl1_wr_start_id3 <= 1'b0; ctrl1_wr_addr_id3 <= DATA_BASE_ID3; ctrl1_wr_data_id3 <= 64'd0;
            ctrl2_wr_start_id3 <= 1'b0; ctrl2_wr_addr_id3 <= COUNT_BASE_ID3; ctrl2_wr_data_id3 <= 32'd0;
        end else begin
            case (ch_state_id3)
                CH_IDLE: begin
                    ctrl1_wr_start_id3 <= 1'b0; ctrl2_wr_start_id3 <= 1'b0;
                    if (clear_counter) begin
                        ctrl2_wr_start_id3 <= 1'b1; ctrl2_wr_addr_id3 <= COUNT_BASE_ID3; ctrl2_wr_data_id3 <= 32'd0;
                        task_count_id3 <= 32'd0; write_addr_ptr_id3 <= DATA_BASE_ID3;
                        ch_state_id3 <= CH_WAIT_CNT_DONE;
                    end else if (info_valid_id3 && !threshold_sent) begin
                        ctrl1_wr_addr_id3 <= write_addr_ptr_id3; ctrl1_wr_data_id3 <= sub_board_info_type2_id3;ctrl1_wr_start_id3 <= 1'b1;
                        ch_state_id3 <= CH_WAIT_DATA_DONE;
                    end else begin
                        ch_state_id3 <= ch_state_id3;
                    end
                end
                CH_WAIT_DATA_DONE: begin
                    ctrl1_wr_start_id3 <= 1'b1;
                    if (ctrl1_wr_done_id3) begin
                        ch_state_id3 <= CH_UPDATE_DATA;
                    end else begin
                        ch_state_id3 <= ch_state_id3;
                    end
                end
                CH_UPDATE_DATA: begin
                    ctrl1_wr_start_id3 <= 1'b0;
                    write_addr_ptr_id3 <= write_addr_ptr_id3 + 32'd8;
                    task_count_id3 <= task_count_id3 + 1;
                    ctrl2_wr_addr_id3 <= COUNT_BASE_ID3; ctrl2_wr_data_id3 <= task_count_id3 + 1; //ctrl2_wr_start_id3 <= 1'b1;
                    ch_state_id3 <= CH_WAIT_CNT_DONE;
                end
                CH_WAIT_CNT_DONE: begin
                    ctrl2_wr_start_id3 <= 1'b1;
                    if (ctrl2_wr_done_id3) begin
                        ctrl2_wr_start_id3 <= 1'b0;
                        ch_state_id3 <= CH_IDLE;
                    end else begin
                        ch_state_id3 <= ch_state_id3;
                    end
                end
                default: ch_state_id3 <= CH_IDLE;
            endcase
        end
    end

    // Global threshold detection and pulse fan-out
    // Uses done strobes and state to anticipate next total count.
    wire inc_ch0 = (ch_state_id0 == CH_WAIT_DATA_DONE) && ctrl1_wr_done_id0 && !clear_counter;
    wire inc_ch1 = (ch_state_id1 == CH_WAIT_DATA_DONE) && ctrl1_wr_done_id1 && !clear_counter;
    wire inc_ch2 = (ch_state_id2 == CH_WAIT_DATA_DONE) && ctrl1_wr_done_id2 && !clear_counter;
    wire inc_ch3 = (ch_state_id3 == CH_WAIT_DATA_DONE) && ctrl1_wr_done_id3 && !clear_counter;

    wire [31:0] aggregated_next_sum = task_count_id0 + task_count_id1 + task_count_id2 + task_count_id3 +
                                      (inc_ch0?32'd1:32'd0) + (inc_ch1?32'd1:32'd0) + (inc_ch2?32'd1:32'd0) + (inc_ch3?32'd1:32'd0);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            threshold_sent <= 1'b0;
//            threshold_reached <= 1'b0;
        end else begin
            // default low pulse
            // threshold_reached <= 1'b0;
            if (clear_counter) begin
                threshold_sent <= 1'b0;
            end else if (!threshold_sent && (aggregated_next_sum >= THRESHOLD)) begin
                // threshold_reached <= 1'b1;
                threshold_sent <= 1'b1;
            end
            else begin
                threshold_sent <= threshold_sent;
            end
        end
    end

endmodule