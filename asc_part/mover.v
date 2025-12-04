module mover(

    // Control Signals
    input MOVE_START,
    input[7:0] MOVE_NUM,
    input[31:0] SOURCE_ADDR,
    input[31:0] DEST_ADDR,
    output MOVE_DONE,

    // BRAM READ Interface
    output reg RD_START,
    output reg [31:0] RD_ADDR,
    input[127:0] RD_DATA,
    input RD_DONE,


    //DDR WRITE Interface
    output reg WR_START,
    output reg [31:0] WR_ADDR,
    output reg [127:0] WR_DATA,
    input WR_DONE,

    

    input ACLK,
    input ARESETN

);

    // State Definition
    localparam [2:0] IDLE       = 3'd0;
    localparam [2:0] READ_CMD   = 3'd1;
    localparam [2:0] READ_WAIT  = 3'd2;
    localparam [2:0] WRITE_CMD  = 3'd3;
    localparam [2:0] WRITE_WAIT = 3'd4;
    localparam [2:0] DONE       = 3'd5;

    reg [2:0] current_state, next_state;
    reg [7:0] move_cnt;
    reg [127:0] data_buffer;

    // State Transition
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Next State Logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (MOVE_START)
                    next_state = READ_CMD;
                else
                    next_state = IDLE;
            end
            READ_CMD: begin
                next_state = READ_WAIT;
            end
            READ_WAIT: begin
                if (RD_DONE)
                    next_state = WRITE_CMD;
                else
                    next_state = READ_WAIT;
            end
            WRITE_CMD: begin
                next_state = WRITE_WAIT;
            end
            WRITE_WAIT: begin
                if (WR_DONE) begin
                    if (move_cnt == MOVE_NUM - 1)
                        next_state = DONE;
                    else
                        next_state = READ_CMD;
                end else begin
                    next_state = WRITE_WAIT;
                end
            end
            DONE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Output Logic & Data Path
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            RD_START    <= 1'b0;
            RD_ADDR     <= 32'd0;
            WR_START    <= 1'b0;
            WR_ADDR     <= 32'd0;
            WR_DATA     <= 128'd0;
            move_cnt    <= 8'd0;
            data_buffer <= 128'd0;
        end else begin
            // Default Pulse Signals
            RD_START <= 1'b0;
            WR_START <= 1'b0;

            case (current_state)
                IDLE: begin
                    move_cnt <= 8'd0;
                    if (MOVE_START) begin
                        // Initialize addresses
                        RD_ADDR <= SOURCE_ADDR;
                        WR_ADDR <= DEST_ADDR;
                    end
                end

                READ_CMD: begin
                    RD_START <= 1'b1;
                end

                READ_WAIT: begin
                    if (RD_DONE) begin
                        data_buffer <= RD_DATA; // Capture read data
                    end
                end

                WRITE_CMD: begin
                    WR_START <= 1'b1;
                    WR_DATA  <= data_buffer;
                end

                WRITE_WAIT: begin
                    if (WR_DONE) begin
                        if (move_cnt < MOVE_NUM - 1) begin
                            move_cnt <= move_cnt + 1'b1;
                            // Increment addresses (128 bits = 16 bytes)
                            RD_ADDR  <= RD_ADDR + 32'd16;
                            WR_ADDR  <= WR_ADDR + 32'd16;
                        end
                    end
                end

                DONE: begin
                    // Optional: Keep done signal high or handle in assign
                end
            endcase
        end
    end

    assign MOVE_DONE = (current_state == DONE);

endmodule