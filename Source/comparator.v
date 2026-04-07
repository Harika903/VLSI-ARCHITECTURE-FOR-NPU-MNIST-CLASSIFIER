// ------------------------------------------------------
// Compare two signed 16-bit values, keep max & index
// index: 8-bit for compatibility (returns 8'd1 or 8'd2)
// ------------------------------------------------------
module auto_comparator2 (
  input  wire                 clk,
  input  wire                 rst,
  input  wire                 en,
  input  wire signed [15:0]   a,
  input  wire signed [15:0]   b,
  output reg  signed [15:0]   max_val,
  output reg         [7:0]    max_idx
);
  wire a_ge_b = (a >= b);

  always @(posedge clk) begin
    if (rst) begin
      max_val <= 16'sd0;
      max_idx <= 8'd0;
    end else if (en) begin
      if (a_ge_b) begin
        max_val <= a;
        max_idx <= 8'd1;
      end else begin
        max_val <= b;
        max_idx <= 8'd2;
      end
    end
  end
endmodule
