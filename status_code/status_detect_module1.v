// 状态检测模块：收集4个子板的两类信息，第一类直接输出，第二类整合写入BRAM
module status_detect_module1 (

    // 子板信息输入接口
    input                  info_valid_id0,
    input                  info_valid_id1,
    input                  info_valid_id2,
    input                  info_valid_id3,
    // 第一类信息（空余内存+未完成任务）
    input [63:0] sub_board_info_type1_id0,
    input [63:0] sub_board_info_type1_id1,
    input [63:0] sub_board_info_type1_id2,
    input [63:0] sub_board_info_type1_id3,


    // 第一类信息输出接口
    output reg   [31:0]    out_free_mem_id0,      // 输出的空余内存
    output reg   [31:0]    out_pending_tasks_id0, // 输出的未完成任务数
    output reg             out_info1_valid_id0,   // 第一类信息输出有效标志

    output reg   [31:0]    out_free_mem_id1,      // 输出的空余内存
    output reg   [31:0]    out_pending_tasks_id1, // 输出的未完成任务数
    output reg             out_info1_valid_id1,   // 第一类信息输出有效标志

    output reg   [31:0]    out_free_mem_id2,      // 输出的空余内存
    output reg   [31:0]    out_pending_tasks_id2, // 输出的未完成任务数
    output reg             out_info1_valid_id2,   // 第一类信息输出有效标志

    output reg   [31:0]    out_free_mem_id3,      // 输出的空余内存
    output reg   [31:0]    out_pending_tasks_id3, // 输出的未完成任务数
    output reg             out_info1_valid_id3,   // 第一类信息输出有效标志


    input                  clk,            // 时钟
    input                  rst_n          // 复位（低有效）

);



// 时序逻辑：信息处理
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_free_mem_id0 <= 32'd0;
        out_pending_tasks_id0 <= 32'd0;
        out_info1_valid_id0 <= 1'b0;
    end else if (info_valid_id0) begin
        // 更新第一类信息输出
        out_free_mem_id0 <= {sub_board_info_type1_id0[63:32]}; // 假设空余内存为32位，取高32位
        out_pending_tasks_id0 <= sub_board_info_type1_id0[31:0];   // 假设未完成任务数为32位，取低32位
        out_info1_valid_id0 <= 1'b1;

    end else begin
        out_info1_valid_id0 <= 1'b0; // 无效时清除有效标志
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_free_mem_id1 <= 32'd0;
        out_pending_tasks_id1 <= 32'd0;
        out_info1_valid_id1 <= 1'b0;
    end else if (info_valid_id1) begin
        // 更新第一类信息输出
        out_free_mem_id1 <= {sub_board_info_type1_id1[63:32]}; // 假设空余内存为32位，取高32位
        out_pending_tasks_id1 <= sub_board_info_type1_id1[31:0];   // 假设未完成任务数为32位，取低32位
        out_info1_valid_id1 <= 1'b1;

    end else begin
        out_info1_valid_id1 <= 1'b0; // 无效时清除有效标志
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_free_mem_id2 <= 32'd0;
        out_pending_tasks_id2 <= 32'd0;
        out_info1_valid_id2 <= 1'b0;
    end else if (info_valid_id2) begin
        // 更新第一类信息输出
        out_free_mem_id2 <= {sub_board_info_type1_id2[63:32]}; // 假设空余内存为32位，取高32位
        out_pending_tasks_id2 <= sub_board_info_type1_id2[31:0];   // 假设未完成任务数为32位，取低32位
        out_info1_valid_id2 <= 1'b1;

    end else begin
        out_info1_valid_id2 <= 1'b0; // 无效时清除有效标志
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_free_mem_id3 <= 32'd0;
        out_pending_tasks_id3 <= 32'd0;
        out_info1_valid_id3 <= 1'b0;
    end else if (info_valid_id3) begin
        // 更新第一类信息输出
        out_free_mem_id3 <= {sub_board_info_type1_id3[63:32]}; // 假设空余内存为32位，取高32位
        out_pending_tasks_id3 <= sub_board_info_type1_id3[31:0];   // 假设未完成任务数为32位，取低32位
        out_info1_valid_id3 <= 1'b1;

    end else begin
        out_info1_valid_id3 <= 1'b0; // 无效时清除有效标志
    end
end

endmodule