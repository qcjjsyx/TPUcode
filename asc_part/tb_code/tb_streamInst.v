`timescale 1ns / 1ps
module tb_streamInst();

wire FINISH;
reg CAN_READ_INST;
reg rst;

initial begin
    rst = 1'b1;
    #100;
    rst = 1'b0;
    #1000;
    rst = 1'b1;

end

reg[127:0] MEM_SEND_INST_BRAM[0:7];
reg[127:0] MEM_SEND_DATA_BRAM[0:7];
reg[127:0] MEM_GET_DATA_BRAM[0:7];
reg[127:0] MEM_FREE_BRAM[0:7];



initial begin
  CAN_READ_INST = 1'b0;
end

stream_inst u_stream_inst(
    .CAN_READ_INST      ( CAN_READ_INST      ),
    .FINISH             ( FINISH            ),
    .STATUS_SEND        (         ),
    .STATUS_INFO        (         ),
    .RD_START           (            ),
    .RD_ADDR            (             ),
    .RD_DATA            (             ),
    .RD_DONE            (             ),
    .o_drive2Mover1     (      ),
    .i_freeF_Mover1     (      ),
    .o_data2Mover1      (       ),
    .o_drive2Mover2     (      ),
    .i_freeF_Mover2     (      ),
    .o_data2Mover2      (       ),
    .o_drive2TPU        (         ),
    .i_freeFTPU         (          ),
    .o_data2TPU_128     (      ),
    .o_finish2TPU       (        ),
    .i_driveFTPU        (         ),
    .o_free2TPU         (          ),
    .i_dataFTPU_128     (      ),
    .i_finishFTPU       (        ),
    .i_driveFTPU_STATUS (  ),
    .o_free2TPU_STATUS  (   ),
    .i_dataFTPU_STATUS  (   ),
    .rst                ( rst                )
);





endmodule