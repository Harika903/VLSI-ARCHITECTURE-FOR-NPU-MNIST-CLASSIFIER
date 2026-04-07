`timescale 1ns/1ps

module tb_relu;
  reg clk, rst, EN_ReLU, BYPASS_ReLU;
  reg signed [15:0] x_in;
  wire signed [15:0] x_out;

  relu16 uut (
    .clk(clk), .rst(rst), .EN_ReLU(EN_ReLU), .BYPASS_ReLU(BYPASS_ReLU),
    .x_in(x_in), .x_out(x_out)
  );

  always #5 clk = ~clk;

  initial begin
    clk=0; rst=1; EN_ReLU=1; BYPASS_ReLU=0; x_in=0;
    #10 rst=0;

    // Case 1: Positive input
    x_in=16'sd25; #10;

    // Case 2: Negative input (ReLU should output 0)
    x_in=-16'sd40; #10;

    // Case 3: Bypass mode
    BYPASS_ReLU=1; x_in=-16'sd20; #10;

    // Case 4: Disable ReLU
    EN_ReLU=0; x_in=16'sd100; #10;

    #50 $finish;
  end
endmodule

