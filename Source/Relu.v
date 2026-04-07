// ------------------------------------
// ReLU16 with enable and bypass control
// If EN_ReLU=0 -> output zeros (blocked)
// If BYPASS=1  -> pass-through input
// Else         -> max(0, x)
// ------------------------------------
module relu16 (
  input  wire                 clk,
  input  wire                 rst,
  input  wire                 EN_ReLU,
  input  wire                 BYPASS_ReLU,
  input  wire signed [15:0]   x_in,
  output reg  signed [15:0]   x_out
);
  wire signed [15:0] relu_val = (x_in[15]) ? 16'sd0 : x_in;
  wire signed [15:0] mux_val  = BYPASS_ReLU ? x_in : relu_val;
  wire signed [15:0] gate_val = EN_ReLU ? mux_val : 16'sd0;

  always @(posedge clk) begin
    if (rst) x_out <= 16'sd0;
    else     x_out <= gate_val;
  end
endmodule

