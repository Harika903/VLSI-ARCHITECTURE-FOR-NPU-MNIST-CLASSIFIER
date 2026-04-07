`timescale 1ns/1ps

module tb_piso;
  reg clk, rst, en, load;
  reg [15:0] w1, w2;
  wire [7:0] dout;
  wire busy, done;

  piso_2x16_to_8 uut (
    .clk(clk), .rst(rst), .en(en), .load(load),
    .w1(w1), .w2(w2), .dout(dout), .busy(busy), .done(done)
  );

  always #5 clk=~clk;

  initial begin
    clk=0; rst=1; en=0; load=0; w1=0; w2=0;
    #10 rst=0;

    // Load words
    w1=16'h1234; w2=16'hABCD; load=1; #10 load=0;

    // Shift out 4 bytes
    en=1; #40;

    en=0; #20 $finish;
  end
endmodule
