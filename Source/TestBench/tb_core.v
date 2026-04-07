`timescale 1ns/1ps

module tb_npu_core;

    reg clk;
    reg rst;

    reg [7:0] DA, DB, DC, DD;

    reg EN_BUF_IN;
    reg EN_MAC;
    reg EN_ReLU;
    reg LATCH_RELU;
    reg FIFO_WR_EN;

    reg [2:0] SEL_OUT;

    wire [7:0] D_OUT;
    wire FIFO_FULL;
    wire FIFO_EMPTY;

    // Clock: 10 ns period
    always #5 clk = ~clk;

    // DUT
    npu_core_top dut (
        .clk(clk),
        .rst(rst),

        .DA(DA), .DB(DB), .DC(DC), .DD(DD),

        .EN_BUF_IN(EN_BUF_IN),
        .EN_MAC(EN_MAC),
        .EN_ReLU(EN_ReLU),
        .LATCH_RELU(LATCH_RELU),
        .FIFO_WR_EN(FIFO_WR_EN),

        .SEL_OUT(SEL_OUT),

        .D_OUT(D_OUT),
        .FIFO_FULL(FIFO_FULL),
        .FIFO_EMPTY(FIFO_EMPTY)
    );

    initial begin
        // Init
        clk = 0;
        rst = 1;

        EN_BUF_IN  = 0;
        EN_MAC     = 0;
        EN_ReLU    = 0;
        LATCH_RELU = 0;
        FIFO_WR_EN = 0;

        SEL_OUT = 3'b001;

        DA = 8'd4;
        DB = 8'd2;
        DC = 8'd3;
        DD = 8'd1;

        #20 rst = 0;

        // Load input buffer
        #10 EN_BUF_IN = 1;
        #10 EN_BUF_IN = 0;

        // MAC + ReLU
        #10 EN_MAC  = 1;
            EN_ReLU = 1;
        #20 EN_MAC  = 0;
            EN_ReLU = 0;

        // Latch + FIFO write
        #10 LATCH_RELU = 1;
            FIFO_WR_EN = 1;
        #10 LATCH_RELU = 0;
            FIFO_WR_EN = 0;

        #50 $stop;
    end

endmodule

