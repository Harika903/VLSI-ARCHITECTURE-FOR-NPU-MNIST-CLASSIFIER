// ------------------------------------------------------
// 2 ReLU outputs (16b each) ? split to 4 bytes & latch
// ------------------------------------------------------
module relu_stage_latch (
  input  wire         clk,
  input  wire         rst,
  input  wire         en,
  input  wire [15:0]  relu1,
  input  wire [15:0]  relu2,
  output wire [7:0]   r1_hi, r1_lo, r2_hi, r2_lo
);
  dff #(.W(8)) ff_r1_hi (.clk(clk), .rst(rst), .en(en), .d(relu1[15:8]), .q(r1_hi));
  dff #(.W(8)) ff_r1_lo (.clk(clk), .rst(rst), .en(en), .d(relu1[7:0]),  .q(r1_lo));
  dff #(.W(8)) ff_r2_hi (.clk(clk), .rst(rst), .en(en), .d(relu2[15:8]), .q(r2_hi));
  dff #(.W(8)) ff_r2_lo (.clk(clk), .rst(rst), .en(en), .d(relu2[7:0]),  .q(r2_lo));
endmodule

