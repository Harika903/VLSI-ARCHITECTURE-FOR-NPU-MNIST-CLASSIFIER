// ------------------------------------------------------------
// MAC: y = sat( (a * b) + (sel_bias ? bias : acc_prev) )
// Internally stores previous accumulator in a DFF when en_mac
// ------------------------------------------------------------
module mac_8x8_to_16 (
  input  wire                 clk,
  input  wire                 rst,
  input  wire                 en_mac,       // enable storage
  input  wire                 rst_mac,      // clear accumulator
  input  wire signed  [7:0]   a,            // input data
  input  wire signed  [7:0]   b,            // weight
  input  wire signed [15:0]   bias,         // sign-extended bias
  input  wire                 sel_bias,     // 1: use bias as base, 0: use acc_prev
  output reg  signed [15:0]   acc_out       // registered output
);
  reg  signed [15:0] acc_prev;
  wire signed [15:0] mult  = a * b;
  wire signed [15:0] base  = sel_bias ? bias : acc_prev;
  wire signed [15:0] sum_sat;

  sat_add16 u_add (.a(mult), .b(base), .y(sum_sat));

  always @(posedge clk) begin
    if (rst | rst_mac) begin
      acc_prev <= 16'sd0;
      acc_out  <= 16'sd0;
    end else if (en_mac) begin
      acc_prev <= sum_sat;
      acc_out  <= sum_sat;
    end
  end
endmodule

