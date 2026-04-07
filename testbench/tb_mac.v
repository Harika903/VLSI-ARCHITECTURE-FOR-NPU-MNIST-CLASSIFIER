`timescale 1ns/1ps

module tb_mac;

    reg clk;
    reg rst;
    reg en_mac;
    reg rst_mac;

    reg signed [7:0] a, b;
    wire signed [15:0] acc_out;

    always #5 clk = ~clk;

    mac_8x8_to_16 dut (
        .clk(clk),
        .rst(rst),
        .en_mac(en_mac),
        .rst_mac(rst_mac),
        .a(a),
        .b(b),
        .bias(16'd0),
        .sel_bias(1'b0),
        .acc_out(acc_out)
    );

    initial begin
        clk = 0;
        rst = 1;
        rst_mac = 1;
        en_mac = 0;

        a = 0;
        b = 0;

        #20;
        rst = 0;
        rst_mac = 0;

        a = 4;
        b = 2;

        en_mac = 1;

        repeat (8) begin
            @(posedge clk);
        end

        $display("MAC output = %d (expected 32)", acc_out);

        #20;
        $finish;
    end

endmodule
