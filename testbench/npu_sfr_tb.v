`timescale 1ns/1ps

module tb_npu_sfr;

    // -------------------------
    // Signals
    // -------------------------
    reg         clk;
    reg         rst;

    reg         wr_en;
    reg  [3:0]  addr;
    reg  [31:0] wr_data;

    wire        START;
    wire        EN_ReLU;
    wire        BYPASS_ReLU;
    wire [2:0]  SEL_OUT;

    reg         done;
    reg         fifo_full;
    reg         fifo_empty;

    // -------------------------
    // Clock generation
    // -------------------------
    always #5 clk = ~clk;   // 10 ns period

    // -------------------------
    // DUT: SFR
    // -------------------------
    npu_sfr dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .addr(addr),
        .wr_data(wr_data),
        .done(done),
        .fifo_full(fifo_full),
        .fifo_empty(fifo_empty),
        .START(START),
        .EN_ReLU(EN_ReLU),
        .BYPASS_ReLU(BYPASS_ReLU),
        .SEL_OUT(SEL_OUT)
    );

    // -------------------------
    // Test sequence
    // -------------------------
    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        wr_en = 0;
        addr = 0;
        wr_data = 0;

        done = 0;
        fifo_full = 0;
        fifo_empty = 1;

        #20 rst = 0;   // Release reset

        // -------------------------
        // Write CTRL_REG
        // START=1, EN_ReLU=1
        // -------------------------
        #10;
        wr_en   = 1;
        addr    = 4'h0;
        wr_data = 32'b0000_0011;
        #10 wr_en = 0;

        // -------------------------
        // Write OUTSEL_REG
        // -------------------------
        #10;
        wr_en   = 1;
        addr    = 4'h8;
        wr_data = 32'b0000_0101;  // SEL_OUT = 101
        #10 wr_en = 0;

        // -------------------------
        // Simulate NPU done
        // -------------------------
        #30 done = 1;

        #20;
        $stop;
    end

endmodule
