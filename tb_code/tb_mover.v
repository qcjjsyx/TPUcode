`timescale 1ns / 1ps

module tb_mover;
    localparam DATA_WIDTH = 128;
    localparam ADDR_WIDTH = 32;

    reg         MOVE_START;
    reg  [7:0]  MOVE_NUM;
    reg  [ADDR_WIDTH-1:0] SOURCE_ADDR;
    reg  [ADDR_WIDTH-1:0] DEST_ADDR;
    wire        MOVE_DONE;

    wire        RD_START;
    wire [ADDR_WIDTH-1:0] RD_ADDR;
    reg  [DATA_WIDTH-1:0] RD_DATA;
    reg         RD_DONE;

    wire        WR_START;
    wire [ADDR_WIDTH-1:0] WR_ADDR;
    wire [DATA_WIDTH-1:0] WR_DATA;
    reg         WR_DONE;

    reg         ACLK;
    reg         ARESETN;

    // Clock Generation
    initial begin
        ACLK = 1'b0;
        forever #2.5 ACLK = ~ACLK; // 200MHz
    end

    // DUT Instantiation
    mover u_mover(
        .MOVE_START  ( MOVE_START  ),
        .MOVE_NUM    ( MOVE_NUM    ),
        .SOURCE_ADDR ( SOURCE_ADDR ),
        .DEST_ADDR   ( DEST_ADDR   ),
        .MOVE_DONE   ( MOVE_DONE   ),
        .RD_START    ( RD_START    ),
        .RD_ADDR     ( RD_ADDR     ),
        .RD_DATA     ( RD_DATA     ),
        .RD_DONE     ( RD_DONE     ),
        .WR_START    ( WR_START    ),
        .WR_ADDR     ( WR_ADDR     ),
        .WR_DATA     ( WR_DATA     ),
        .WR_DONE     ( WR_DONE     ),
        .ACLK        ( ACLK        ),
        .ARESETN     ( ARESETN     )
    );

    // Mock Read Response
    initial begin
        RD_DONE = 0;
        RD_DATA = 0;
        forever begin
            @(negedge ACLK);
            if (RD_START) begin
                // Simulate Read Latency (e.g., 20ns)
                #20; 
                RD_DATA = {4{RD_ADDR}}; // Generate some data based on address
                RD_DONE = 1;
                #5;
                RD_DONE = 0;
            end
        end
    end

    // Mock Write Response
    initial begin
        WR_DONE = 0;
        forever begin
            @(negedge ACLK);
            if (WR_START) begin
                // Simulate Write Latency
                #20;
                WR_DONE = 1;
                // Optional: Check data
                $display("Time %t: Write at Addr %h, Data %h", $time, WR_ADDR, WR_DATA);
                #5;
                WR_DONE = 0;
            end
        end
    end

    // Test Stimulus
    initial begin
        // Initialize Inputs
        ARESETN = 1'b0;
        MOVE_START = 1'b0;
        MOVE_NUM = 0;
        SOURCE_ADDR = 0;
        DEST_ADDR = 0;

        // Reset
        #1000;
        ARESETN = 1'b1;
        #100;

        // Test Case 1: Simple Move 4 items
        $display("Starting Test Case 1: Move 4 items");
        SOURCE_ADDR = 32'h1000_0000;
        DEST_ADDR   = 32'h2000_0000;
        MOVE_NUM    = 8'd4;
        
        @(negedge ACLK);
        MOVE_START = 1'b1;
        @(negedge ACLK);
        MOVE_START = 1'b0;

        wait(MOVE_DONE==1);
        $display("Test Case 1 Completed");
        #500;

        // Test Case 2: Move 10 items with different addresses
        $display("Starting Test Case 2: Move 10 items");
        SOURCE_ADDR = 32'h3000_0000;
        DEST_ADDR   = 32'h4000_0000;
        MOVE_NUM    = 8'd10;
        
        @(negedge ACLK);
        MOVE_START = 1'b1;
        @(negedge ACLK);
        MOVE_START = 1'b0;

        wait(MOVE_DONE==1);
        $display("Test Case 2 Completed");
        #100;

        $stop;
    end

endmodule