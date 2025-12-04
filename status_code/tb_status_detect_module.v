`timescale 1ns / 1ps
// Testbench for status_top integrating splitter/module1/module2 (multi-channel)
module tb_status_detect_module;

    // Clock & reset
    reg clk;
    reg rst_n;

    // Upstream 128-bit info inputs (splitter will slice)
    reg  [127:0] info_in_id0;
    reg  [127:0] info_in_id1;
    reg  [127:0] info_in_id2;
    reg  [127:0] info_in_id3;
    reg          valid_in_id0;
    reg          valid_in_id1;
    reg          valid_in_id2;
    reg          valid_in_id3;
    reg         clear_counter;

    // Module1 observation outputs
    wire [31:0] out_free_mem_id0, out_pending_tasks_id0; wire out_info1_valid_id0;
    wire [31:0] out_free_mem_id1, out_pending_tasks_id1; wire out_info1_valid_id1;
    wire [31:0] out_free_mem_id2, out_pending_tasks_id2; wire out_info1_valid_id2;
    wire [31:0] out_free_mem_id3, out_pending_tasks_id3; wire out_info1_valid_id3;

    // Status signals
    wire        upstream_busy;
    wire        threshold_reached;

    // Controller write interfaces (data channels)
    // wire        ctrl1_wr_start_id0; wire [31:0] ctrl1_wr_addr_id0; wire [63:0] ctrl1_wr_data_id0; reg ctrl1_wr_done_id0;
    // wire        ctrl1_wr_start_id1; wire [31:0] ctrl1_wr_addr_id1; wire [63:0] ctrl1_wr_data_id1; reg ctrl1_wr_done_id1;
    // wire        ctrl1_wr_start_id2; wire [31:0] ctrl1_wr_addr_id2; wire [63:0] ctrl1_wr_data_id2; reg ctrl1_wr_done_id2;
    // wire        ctrl1_wr_start_id3; wire [31:0] ctrl1_wr_addr_id3; wire [63:0] ctrl1_wr_data_id3; reg ctrl1_wr_done_id3;

    // Controller write interfaces (count channels)
    // wire        ctrl2_wr_start_id0; wire [31:0] ctrl2_wr_addr_id0; wire [31:0] ctrl2_wr_data_id0; reg ctrl2_wr_done_id0;
    // wire        ctrl2_wr_start_id1; wire [31:0] ctrl2_wr_addr_id1; wire [31:0] ctrl2_wr_data_id1; reg ctrl2_wr_done_id1;
    // wire        ctrl2_wr_start_id2; wire [31:0] ctrl2_wr_addr_id2; wire [31:0] ctrl2_wr_data_id2; reg ctrl2_wr_done_id2;
    // wire        ctrl2_wr_start_id3; wire [31:0] ctrl2_wr_addr_id3; wire [31:0] ctrl2_wr_data_id3; reg ctrl2_wr_done_id3;

    // Instantiate integrated top
status_detect_top u_status_detect_top(
    .clear_sig             ( clear_counter             ),
    .info_in_id0           ( info_in_id0           ),
    .valid_in_id0          ( valid_in_id0          ),
    .out_free_mem_id0      ( out_free_mem_id0      ),
    .out_pending_tasks_id0 ( out_pending_tasks_id0 ),
    .out_info1_valid_id0   ( out_info1_valid_id0   ),
    .info_in_id1           ( info_in_id1           ),
    .valid_in_id1          ( valid_in_id1          ),
    .out_free_mem_id1      ( out_free_mem_id1      ),
    .out_pending_tasks_id1 ( out_pending_tasks_id1 ),
    .out_info1_valid_id1   ( out_info1_valid_id1   ),
    .info_in_id2           ( info_in_id2           ),
    .valid_in_id2          ( valid_in_id2          ),
    .out_free_mem_id2      ( out_free_mem_id2      ),
    .out_pending_tasks_id2 ( out_pending_tasks_id2 ),
    .out_info1_valid_id2   ( out_info1_valid_id2   ),
    .info_in_id3           ( info_in_id3           ),
    .valid_in_id3          ( valid_in_id3          ),
    .out_free_mem_id3      ( out_free_mem_id3      ),
    .out_pending_tasks_id3 ( out_pending_tasks_id3 ),
    .out_info1_valid_id3   ( out_info1_valid_id3   ),
    .upstream_busy         ( upstream_busy         ),
    .threshold_reached     ( threshold_reached     ),
    .ACLK                  ( clk                  ),
    .ARESETN               ( rst_n               )
);



    // Clock (5ns period ~200MHz)
    initial begin
        clk = 0;
        forever #2.5 clk = ~clk;
    end

    
    // Stimulus helpers
    // Helper to assemble 128-bit upstream packet: high 64 (module1) + low 64 (module2)
    function [127:0] pack_info(input [31:0] free_mem, input [31:0] pending_tasks, input [63:0] payload_low64);
        begin
            pack_info = {free_mem, pending_tasks, payload_low64};
        end
    endfunction

    task send_packet(input integer ch, input [31:0] free_mem, input [31:0] pending_tasks, input [63:0] payload);
        begin
            @(negedge clk);
            case(ch)
                0: begin info_in_id0 = pack_info(free_mem,pending_tasks,payload); valid_in_id0 = 1; end
                1: begin info_in_id1 = pack_info(free_mem,pending_tasks,payload); valid_in_id1 = 1; end
                2: begin info_in_id2 = pack_info(free_mem,pending_tasks,payload); valid_in_id2 = 1; end
                3: begin info_in_id3 = pack_info(free_mem,pending_tasks,payload); valid_in_id3 = 1; end
            endcase
            @(negedge clk);
            valid_in_id0 = 0; valid_in_id1 = 0; valid_in_id2 = 0; valid_in_id3 = 0;
        end
    endtask

    task wait_idle(); 
        begin 
            @(negedge clk); // Ensure we sample stable busy
            // Wait if busy (processing) or threshold reached (full/waiting for clear)
            while (upstream_busy || threshold_reached) begin
                @(negedge clk); 
            end
        end 
    endtask


   
    integer i;
    initial begin
        rst_n = 1;
        #100
        rst_n = 0;
        info_in_id0 = 0; info_in_id1 = 0; info_in_id2 = 0; info_in_id3 = 0;
        valid_in_id0 = 0; valid_in_id1 = 0; valid_in_id2 = 0; valid_in_id3 = 0;
        clear_counter = 0;
        #1000; rst_n = 1; #50;

        // 1) Basic single channel write (free_mem=1000 pending=5)
        $display("%t Starting single-channel test", $time);
        wait_idle(); send_packet(0, 32'd1000, 32'd5, 64'hAA55_0000_0000_0001); wait_idle();
        $display("%t Completed single-channel test", $time);
        # 100

        // 2) Parallel issue on different cycles (staggered)
        $display("%t Starting staggered multi-channel test", $time);
        for (i=0; i<4; i=i+1) begin
            wait_idle(); send_packet(i, 32'd2000+i, 32'd10+i, 64'h1111_0000_0000_0000 + i);
        end
        wait_idle();
        $display("%t Completed staggered multi-channel test", $time);

        #100
        // 3) 同时来4个信号
        $display("%t Starting simultaneous multi-channel test", $time);
        wait_idle();
        @(negedge clk);
        info_in_id0 = pack_info(32'd3000, 32'd20, 64'hAAAA_0000_0000_0000); valid_in_id0 = 1;
        info_in_id1 = pack_info(32'd3001, 32'd21, 64'hBBBB_0000_0000_0000); valid_in_id1 = 1;
        info_in_id2 = pack_info(32'd3002, 32'd22, 64'hCCCC_0000_0000_0000); valid_in_id2 = 1;
        info_in_id3 = pack_info(32'd3003, 32'd23, 64'hDDDD_0000_0000_0000); valid_in_id3 = 1;
        @(negedge clk);
        valid_in_id0 = 0; valid_in_id1 = 0; valid_in_id2 = 0; valid_in_id3 = 0;
        wait_idle();
        $display("%t Completed simultaneous multi-channel test", $time);
        #100;
        //4) 测试 清0信号
        $display("%t Starting clear operation test", $time);
        wait_idle();
        @(negedge clk);
        clear_counter = 1;
        // wait_idle();
        @(negedge clk);
        clear_counter = 0;
        wait_idle();
        $display("%t Clear operation completed", $time);
        #100;

        // 5) Threshold crossing: distribute writes across channels until total >= 256
//        pattern: 100 on ch0, 80 on ch1, 50 on ch2, 30 on ch3 -> 260 total
        $display("%t Starting threshold crossing test", $time);
        for (i=0; i<100; i=i+1) begin #500; send_packet(0, 32'd3000, 32'd1, {32'hDEAD0000+i,32'hBEEF0000+i}); end
        for (i=0; i<80;  i=i+1) begin #500; send_packet(1, 32'd3001, 32'd2, {32'hD00D0000+i,32'hF00D0000+i}); end
        for (i=0; i<50;  i=i+1) begin #500; send_packet(2, 32'd3002, 32'd3, {32'hABCD0000+i,32'h12340000+i}); end
        for (i=0; i<30;  i=i+1) begin #500; send_packet(3, 32'd3003, 32'd4, {32'hFACE0000+i,32'hC0DE0000+i}); end
        #20;
        $display("%t Threshold crossing test completed", $time);
        #100;

        //6) 测试清零
        $display("%t Starting clear operation after threshold test", $time);
        @(negedge clk); clear_counter = 1; @(negedge clk); clear_counter = 0; wait_idle();
        $display("%t Clear operation after threshold completed", $time);







    
        #500;
        $display("%t TEST FINISHED", $time);
        $finish;
    end

endmodule