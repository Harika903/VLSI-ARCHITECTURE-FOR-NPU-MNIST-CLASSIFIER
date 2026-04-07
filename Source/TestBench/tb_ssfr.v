`timescale 1ns / 1ps

module tb_ssfr;

    reg         clk;
    reg         rst;
    reg         wr_en;
    reg  [3:0]  wr_addr;
    reg         wr_data;

    wire [2:0]  SEL_OUT;
    wire        BYPASS_ReLU1;
    wire        BYPASS_ReLU2;
    wire        EN_COMP;
    wire        RST_COMP;
    wire        EN_FIFO;
    wire        RST_FIFO;
    wire [15:0] SSFR_OUT;

    // DUT
    ssfr dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .SEL_OUT(SEL_OUT),
        .BYPASS_ReLU1(BYPASS_ReLU1),
        .BYPASS_ReLU2(BYPASS_ReLU2),
        .EN_COMP(EN_COMP),
        .RST_COMP(RST_COMP),
        .EN_FIFO(EN_FIFO),
        .RST_FIFO(RST_FIFO),
        .SSFR_OUT(SSFR_OUT)
    );

    // Clock
    always #5 clk = ~clk;

    initial begin
        // Init
        clk     = 0;
        rst     = 1;
        wr_en   = 0;
        wr_addr = 0;
        wr_data = 0;

        // Reset
        #20 rst = 0;

        // Enable computation (SSFR[10])
        #10;
        wr_en   = 1;
        wr_addr = 4'd10;
        wr_data = 1'b1;
        #10 wr_en = 0;

        // Enable FIFO (SSFR[8])
        #10;
        wr_en   = 1;
        wr_addr = 4'd8;
        wr_data = 1'b1;
        #10 wr_en = 0;

        // Select output (SSFR[15:13] = 101)
        #10;
        wr_en   = 1;
        wr_addr = 4'd15; wr_data = 1'b1;
        #10 wr_en = 0;

        #10;
        wr_en   = 1;
        wr_addr = 4'd14; wr_data = 1'b0;
        #10 wr_en = 0;

        #10;
        wr_en   = 1;
        wr_addr = 4'd13; wr_data = 1'b1;
        #10 wr_en = 0;

        #50;
        $stop;
    end

endmodule

