`timescale 1ns / 1ps
//===============================================================================
// Project:        utils
// Module:         ArbMerge_2
// version:        1st version (2025-06-03)
// Author:         Longtao Zhang, Haiyi Wang
// Reviser:        Haiyi Wang, Anping He
// Date:           2025/06/03
// Connect Mail：  whaiyi2024@lzu.edu.cn
// Description:    一个三路ArbMerge模板。多事件输入，不等待/同步所有事件。一路到则一路出，多路到则仲裁一路出。保持未选择数据流。
//===============================================================================
//! 收到i_free 再发o_free

(* dont_touch="true" *)module cArbMerge3_mem#(
    parameter DATA_WIDTH = 32
)(
//! 端口数修改
    /* input & output ports */
    (* dont_touch="true" *)input                   rst,
    (* dont_touch="true" *)input                   i_drive0,   
    (* dont_touch="true" *)input                   i_drive1,
    (* dont_touch="true" *)input                   i_drive2,
    (* dont_touch="true" *)input  [DATA_WIDTH-1:0] i_data0, 
    (* dont_touch="true" *)input  [DATA_WIDTH-1:0] i_data1,
    (* dont_touch="true" *)input  [DATA_WIDTH-1:0] i_data2,
    (* dont_touch="true" *)output                  o_free0, 
    (* dont_touch="true" *)output                  o_free1,
    (* dont_touch="true" *)output                  o_free2,
    (* dont_touch="true" *)output                  o_drive,
    (* dont_touch="true" *)output [DATA_WIDTH-1:0] o_data,
    (* dont_touch="true" *)input                   i_free

);

    localparam N = 3;

    /* wire and reg */
    (* dont_touch="true" *)wire        w_firstPulsereq;
    (* dont_touch="true" *)wire        w_activeLevel;
    (* dont_touch="true" *)wire        w_activeLevel_delayed;
    (* dont_touch="true" *)wire        w_activePulse;
    (* dont_touch="true" *)wire        w_updateTrig;
    (* dont_touch="true" *)wire        w_turnPriority;
    (* dont_touch="true" *)wire        w_turnPriority_delayed;
    (* dont_touch="true" *)wire        w_isValid;
    (* dont_touch="true" *)wire        w_roundTrig;
    (* dont_touch="true" *)wire        w_sendDrive;
    (* dont_touch="true" *)wire        w_roundDrive;
    (* dont_touch="true" *)wire        w_sendFree;
    (* dont_touch="true" *)wire        w_sendFree_delayd;
    (* dont_touch="true" *)wire        w_fire, w_fire_delayed;
    (* dont_touch="true" *)wire [1:0]  w_outRRelay_2, w_outARelay_2;

//! 端口数修改
    (* dont_touch="true" *)wire        w_trig0,  w_trig1,  w_trig2;
    (* dont_touch="true" *)wire        w_req0,   w_req1,   w_req2;
    (* dont_touch="true" *)wire        w_reset0, w_reset1, w_reset2;
    (* dont_touch="true" *)wire [N-1:0]  w_priority;
    (* dont_touch="true" *)wire [N-1:0]  w_validation;
    (* dont_touch="true" *)reg  [N-1:0]  r_priority;

    (* dont_touch="true" *)wire [DATA_WIDTH-1:0] w_data;
    (* dont_touch="true" *)reg  [DATA_WIDTH-1:0] r_data;

    /*------------------------------------------------------------------------------------------------
    1. 每路输入通过 w_req[i] 电平控制 —— 高电平表示当前通路包含未送出的数据
    2. 每路 w_req[i] 电平通过 i_drive[i] 信号敲高；通过 w_reset[i] 信号复位
    ------------------------------------------------------------------------------------------------*/
//! 端口数修改
    assign w_trig0 = i_drive0 | w_reset0;
    assign w_trig1 = i_drive1 | w_reset1;
    assign w_trig2 = i_drive2 | w_reset2;
    contTap tap0(.trig(w_trig0), .req(w_req0), .rst(rst));
    contTap tap1(.trig(w_trig1), .req(w_req1), .rst(rst));
    contTap tap2(.trig(w_trig2), .req(w_req2), .rst(rst));

    assign w_sendFree = i_free;

    /*------------------------------------------------------------------------------------------------
    1. 所有的控制电平进行或操作，得到 w_activeLevel
    2. w_activeLevel 高电平则表示 “当前ArbMerge中存在尚未发出的事件”
    ------------------------------------------------------------------------------------------------*/
//! 端口数修改
    assign w_activeLevel = w_req0 | w_req1 | w_req2;


    // w_activeLevel 的上升沿用以产生初始化轮询的事件（脉冲）
    // eventSource eventSource (.switch(w_activeLevel), .fire(w_activePulse), .rst(rst));
    delay2U activeDelay(.inR(w_activeLevel), .outR(w_activeLevel_delayed), .rst(rst));
    assign w_activePulse = w_activeLevel & ~(~w_activeLevel ^ w_activeLevel_delayed);

    /*------------------------------------------------------------------------------------------------
    1. w_turnPriority 为驱动优先级轮转的事件
    2. 由 w_activePulse 与 w_updateTrig 进行或操作得到：
        a. w_activePulse 为初始化轮询事件（首次被驱动时）
        b. 后续逻辑：若 w_activeLevel 为高电平，表明此时ArbMerge中存在尚未输出的事件，产生 w_updateTrig（非首次驱动）
    ------------------------------------------------------------------------------------------------*/
    assign w_turnPriority = w_activePulse | w_updateTrig;


    /*------------------------------------------------------------------------------------------------
    1. 使用 w_turnPriority 重置优先级 r_priority
    2. r_priority 使用独热码编码
    3. 该实例模块中使用【固定优先级】
        a. 每次从头开始，按照固定顺序轮询 w_req[i]
        b. 若检测到高电平，则跳转到对应的优先级
        c. 优点：优先级不会空转
        d. 缺点：处于优先级末端的事件可能被后续到来的处于优先级前端的事件抢占优先级，导致其长时间无法被选中
    ------------------------------------------------------------------------------------------------*/
    // always @(posedge w_turnPriority or negedge rst) begin
    //     if(!rst)
    //         r_priority = 2'b00;
	//     else            
    //         if     (w_req0) r_priority = 2'b01;
    //         else if(w_req1) r_priority = 2'b10;
    //         else            r_priority = 2'b00;
    // end
    // assign w_priority = r_priority;

    /*------------------------------------------------------------------------------------------------
    1. 下面注释掉的代码使用【轮转优先级】，可根据需求替换上面的代码块
    2. 轮转优先级:
        a. 按照某种顺序“轮转”遍历
        b. 选中后，优先级会停滞在当前优先级的下一级，不会从头开始
        c. 优点：可以相对平均的遍历到所有事件
        d. 缺点：存在优先级置空的情况，处理时间较长
    ------------------------------------------------------------------------------------------------*/
//! 端口数修改
    always @(posedge w_turnPriority or negedge rst) begin
        if(!rst)
            r_priority = 3'b000;
	    else            
            if     (r_priority == 3'b000) r_priority = 3'b001;
            else if(r_priority == 3'b001) r_priority = 3'b010;
            else if(r_priority == 3'b010) r_priority = 3'b100;
            else if(r_priority == 3'b100) r_priority = 3'b001;
            else                          r_priority = 3'b000;
    end
    assign w_priority = r_priority;


    /*------------------------------------------------------------------------------------------------
    1. 匹配优先级 每位优先级与 w_req[i] 进行与操作，得到 w_validation
    2. w_validation[i] 为 1 则表明下面两个同时发生:
        a. ArbMerge的第 i 路存在尚未发出的事件
        b. 优先级电路匹配到了第 i 路
    3. 上述两件事同时发生，说明第 i 路符合仲裁条件，可以被发送出去
    4. w_isValid 由 w_validation 所有位进行或操作的来，表示当前轮 “是否有匹配上的数据通路”
    ------------------------------------------------------------------------------------------------*/
//! 端口数修改
    assign w_validation[0] = w_priority[0]  & w_req0;
    assign w_validation[1] = w_priority[1]  & w_req1;
    assign w_validation[2] = w_priority[2]  & w_req2;
    assign w_isValid = w_validation[0] | w_validation[1] | w_validation[2];


    // 多路数据选择（根据 w_validation_2）
    assign w_data =  (w_validation == 3'b001) ? i_data0 :
                    ((w_validation == 3'b010) ? i_data1 :
                    ((w_validation == 3'b100) ? i_data2 : {DATA_WIDTH{1'b0}}));


    /*------------------------------------------------------------------------------------------------
    1. w_turnPriority 经过延时单元，目的为等待 w_activeLevel 信号更新
    2. 生成驱动下一轮的脉冲信号，由上一轮脉冲信号 w_turnPriority(delay) 得到
    3. w_turnPriority(delay) 相当于请求事件，如果 w_activeLevel 为高电平，则当前ArbMerge中存在未发出事件，继续向下传递脉冲
    4. 与 w_activeLevel 与操作的具体意义:
        a. 对于 ArbMerge 中存在的最后一个事件，其发出完成后，仍会产生 w_updateTrig/w_turnPriority(delay) 脉冲，将优先级向后“更新”一次
        b. 此时 ArbMerge 中已经没有事件，w_activeLevel电平为低电平状态。为阻止 w_turnPriority(delay) 脉冲持续向后传播，进行与操作，隐藏该次脉冲
    ------------------------------------------------------------------------------------------------*/
    delay4U turnPriDelay (.inR(w_turnPriority), .outR(w_turnPriority_delayed), .rst(rst));
    assign w_roundTrig = w_turnPriority_delayed & w_activeLevel;


    /*------------------------------------------------------------------------------------------------
    1. 根据 w_isValid 判断当前是否匹配到了数据流:
        a. 若 w_isValid 为 1，表明当前存在匹配到的数据，w_roundTrig 传递给 w_sendDrive，将数据与事件输出
        b. 若 w_isValid 为 0，表明当前未匹配到数据，w_roundTrig 传递给 w_roundDrive，重新轮转优先级
    ------------------------------------------------------------------------------------------------*/
    assign w_sendDrive  = w_roundTrig & w_isValid;
    assign w_roundDrive = w_roundTrig & (~w_isValid);

    delay2U sendFreeDelay (.inR(w_sendFree), .outR(w_sendFree_delayd), .rst(rst));
    assign w_updateTrig = w_roundDrive | w_sendFree_delayd;


    /*------------------------------------------------------------------------------------------------
    1. 生成各个通路的控制电平（w_req[i]）复位信号 w_reset[i]
    2. 使用 w_sendFree 驱动，该信号到来意味着事件已经传递到了下一级寄存器
    ------------------------------------------------------------------------------------------------*/
//! 端口数修改
    assign w_reset0 = w_priority[0] & w_req0 & w_sendFree; 
    assign w_reset1 = w_priority[1] & w_req1 & w_sendFree;
    assign w_reset2 = w_priority[2] & w_req2 & w_sendFree;
    

    /*------------------------------------------------------------------------------------------------
    1. 发送-中继-接收部分;
    2. 该部分位于 ArbMerge 的单路【输出】端;
    3. 该部分用于匹配时序逻辑.
    ------------------------------------------------------------------------------------------------*/
    sender sender(
        .i_drive (w_sendDrive       ),
        .o_free  (                  ),
        .outR    (w_outRRelay_2[0]  ),
        .i_free  (w_fire            ),
        .rst     (rst               )
    );

    relay relay0(
        .inR     (w_outRRelay_2[0]  ),
        .inA     (w_outARelay_2[0]  ),
        .outR    (w_outRRelay_2[1]  ),
        .outA    (w_outARelay_2[1]  ),
        .fire    (w_fire            ),
	    .rst     (rst               )
    );

    //===============================================================================
    //
    // 其他的 relay[i] 模块可被连接至 relay0 - receiver 之间，生成连续的 fire 信号，匹配不同的时序逻辑
    //
    //===============================================================================

    receiver receiver(
        .inR         (w_outRRelay_2[1]  ),
        .inA         (w_outARelay_2[1]  ),
        .i_freeNext  (i_free            ),
        .rst         (rst               )
    );


    /*------------------------------------------------------------------------------------------------
    1. 时序逻辑匹配部分;
    2. 根据不同的功能，自定义 组合逻辑 + 时许逻辑，完成数据处理.
    ------------------------------------------------------------------------------------------------*/
    always @(posedge w_fire or negedge rst) begin
        if (!rst) begin
            r_data <= {DATA_WIDTH{1'b0}};
        end
        else begin
            r_data <= w_data;
        end
    end


    /* 具体延时大小需根据实际调试更改（整体模块其余各部分延时同理） */
    delay1U outdelay (.inR(w_fire), .outR(w_fire_delayed), .rst(rst));

    /* 连接输出 */
//! 端口数修改
    assign o_drive   = w_fire_delayed;
    assign o_data    = r_data;
    assign o_free0   = w_sendFree & w_priority[0];
    assign o_free1   = w_sendFree & w_priority[1];
    assign o_free2   = w_sendFree & w_priority[2];


    
endmodule
