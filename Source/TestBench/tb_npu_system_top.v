`timescale 1ns/1ps

module tb_npu_system_top;

    // -------------------------
    // Clock & Reset
    // -------------------------
    reg clk;
    reg rst;
    reg start;

    // -------------------------
    // SSFR write interface
    // -------------------------
    reg        wr_en;
    reg [3:0]  wr_addr;
    reg        wr_data;

    // -------------------------
    // NPU inputs
    // -------------------------
    reg [7:0] DA, DB, DC, DD;

    // -------------------------
    // Outputs
    // -------------------------
    wire done;
    wire [7:0] D_OUT;

    // -------------------------
    // Expected result
    // -------------------------
    integer expected_result;

    // -------------------------
    // Clock generation (10 ns)
    // -------------------------
    always #5 clk = ~clk;

    // -------------------------
    // DUT
    // -------------------------
    npu_system_top dut (
        .clk(clk),
        .rst(rst),
        .start(start),

        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),

        .DA(DA),
        .DB(DB),
        .DC(DC),
        .DD(DD),

        .done(done),
        .D_OUT(D_OUT)
    );

    // -------------------------
    // SSFR write task (CLOCK SAFE)
    // -------------------------
    task write_ssfr;
        input [3:0] addr;
        input       data;
        begin
            @(posedge clk);
            wr_en   <= 1'b1;
            wr_addr <= addr;
            wr_data <= data;

            @(posedge clk);
            wr_en   <= 1'b0;
        end
    endtask

    // -------------------------
    // Test sequence
    // -------------------------
    initial begin
        // -------------------------
        // Initialization
        // -------------------------
        clk   = 0;
        rst   = 1;
        start = 0;

        wr_en   = 0;
        wr_addr = 0;
        wr_data = 0;

        // Example inputs
        DA = 8'd4;
        DB = 8'd2;
        DC = 8'd3;
        DD = 8'd1;

        // -------------------------
        // Apply reset
        // -------------------------
        #20 rst = 0;

        // =====================================================
        // SSFR CONFIGURATION
        // =====================================================
        write_ssfr(4'd9,  1'b0);

        // Enable computation
        write_ssfr(4'd10, 1'b1);   // EN_COMP
        // CLEAR compute reset (VERY IMPORTANT)
          // RST_COMP = 0

        // Enable FIFO
        write_ssfr(4'd8,  1'b1);   // EN_FIFO
        // Clear FIFO reset
        write_ssfr(4'd7, 1'b0);   // RST_FIFO = 0


        // Disable ReLU bypass
        write_ssfr(4'd12, 1'b0);   // BYPASS_ReLU1 = 0

// Output select = 000  (FIFO mode)
        write_ssfr(4'd15, 1'b0);
        write_ssfr(4'd14, 1'b0);
        write_ssfr(4'd13, 1'b0);


        // -----------------------------------------------------
        // ACC_COUNT = 8  (SSFR[6:0] = 0001000)
        // -----------------------------------------------------
        write_ssfr(4'd0, 1'b0);
        write_ssfr(4'd1, 1'b0);
        write_ssfr(4'd2, 1'b0);
        write_ssfr(4'd3, 1'b1);   // bit3 = 1 ? 8
        write_ssfr(4'd4, 1'b0);
        write_ssfr(4'd5, 1'b0);
        write_ssfr(4'd6, 1'b0);

        // -----------------------------------------------------
        // Expected result calculation
        // -----------------------------------------------------
        expected_result = 12 * (DA * DB);

        // =====================================================
        // Start NPU operation
        // =====================================================
        @(posedge clk);
        start <= 1'b1;

        @(posedge clk);
        start <= 1'b0;

        // =====================================================
        // Wait for completion
        // =====================================================
        wait (done == 1'b1);

        @(posedge clk);

        // =====================================================
        // PASS / FAIL CHECK
        // =====================================================
        if (D_OUT == expected_result)
            $display("PASS ?  Output = %d, Expected = %d", D_OUT, expected_result);
        else
            $display("FAIL ?  Output = %d, Expected = %d", D_OUT, expected_result);

        // Extra time to observe waveforms
        #200;

        $finish;
    end

endmodule
