`timescale 1ns/1ps

module tb_comparator;
  reg clk, rst, en;
  reg signed [15:0] a, b;
  wire signed [15:0] max_val;
  wire [7:0] max_idx;

  auto_comparator2 uut (
    .clk(clk), .rst(rst), .en(en), .a(a), .b(b),
    .max_val(max_val), .max_idx(max_idx)
  );

  always #5 clk=~clk;

  initial begin
    clk=0; rst=1; en=0; a=0; b=0;
    #10 rst=0;

    // Case 1: a > b
    a=25; b=10; en=1; #10;

    // Case 2: b > a
    a=5; b=30; #10;

    // Case 3: equal values
    a=50; b=50; #10;

    #50 $finish;
  end
endmodule
