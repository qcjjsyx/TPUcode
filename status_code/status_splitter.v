module status_splitter (
    // Input from upstream (4 channels, 128-bit)
    input [127:0] info_in_id0,
    input [127:0] info_in_id1,
    input [127:0] info_in_id2,
    input [127:0] info_in_id3,
    
    input         valid_in_id0,
    input         valid_in_id1,
    input         valid_in_id2,
    input         valid_in_id3,

    output        upstream_busy,

    // Output to module 1 (High 64 bits)
    output [63:0] info_type1_id0,
    output [63:0] info_type1_id1,
    output [63:0] info_type1_id2,
    output [63:0] info_type1_id3,

    output        valid_type1_id0,
    output        valid_type1_id1,
    output        valid_type1_id2,
    output        valid_type1_id3,

    // Output to module 2 (Low 64 bits)
    output [63:0] info_type2_id0,
    output [63:0] info_type2_id1,
    output [63:0] info_type2_id2,
    output [63:0] info_type2_id3,

    output        valid_type2_id0,
    output        valid_type2_id1,
    output        valid_type2_id2,
    output        valid_type2_id3,

    // Input from module 2
    input         module2_busy
);

    // Split data
    assign info_type1_id0 = info_in_id0[127:64];
    assign info_type2_id0 = info_in_id0[63:0];

    assign info_type1_id1 = info_in_id1[127:64];
    assign info_type2_id1 = info_in_id1[63:0];

    assign info_type1_id2 = info_in_id2[127:64];
    assign info_type2_id2 = info_in_id2[63:0];

    assign info_type1_id3 = info_in_id3[127:64];
    assign info_type2_id3 = info_in_id3[63:0];

    // Pass valid signals
    assign valid_type1_id0 = valid_in_id0;
    assign valid_type1_id1 = valid_in_id1;
    assign valid_type1_id2 = valid_in_id2;
    assign valid_type1_id3 = valid_in_id3;

    assign valid_type2_id0 = valid_in_id0;
    assign valid_type2_id1 = valid_in_id1;
    assign valid_type2_id2 = valid_in_id2;
    assign valid_type2_id3 = valid_in_id3;

    // Pass busy signal upstream
    assign upstream_busy = module2_busy;

endmodule
