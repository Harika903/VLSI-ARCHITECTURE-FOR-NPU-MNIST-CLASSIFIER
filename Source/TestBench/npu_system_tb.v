`timescale 1ns / 1ps

module npu_system_tb;

    reg clk;
    reg rst;
    reg start;
    reg [7:0] DA, DB, DC, DD;
    wire [7:0] D_OUT;
    wire done;

    // Instantiate DUT
    npu_system_top DUT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .DA(DA), .DB(DB), .DC(DC), .DD(DD),
        .D_OUT(D_OUT),
        .done(done)
    );

    // Clock generation (10 ns period)
    always #5 clk = ~clk;

    initial begin
        // Init
        clk = 0;
        rst = 1;
        start = 0;
        DA = 0; DB = 0; DC = 0; DD = 0;

        // Reset release
        #20 rst = 0;

        // Apply input
        #10;
        DA = 8'd12;
        DB = 8'd3;
        DC = 8'd5;
        DD = 8'd2;

        // Start inference
        #10 start = 1;
        #10 start = 0;

        // Wait for done
        wait(done);

        #50;
        $stop;
    end

endmodule

