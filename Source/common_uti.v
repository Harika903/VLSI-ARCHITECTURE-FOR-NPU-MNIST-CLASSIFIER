// ------------------------
// Simple parameterized DFF
// ------------------------
module dff #(parameter W=8)(
  input  wire             clk,
  input  wire             rst,       // sync reset (active-high)
  input  wire             en,        // clock enable
  input  wire [W-1:0]     d,
  output reg  [W-1:0]     q
);
  always @(posedge clk) begin
    if (rst) q <= {W{1'b0}};
    else if (en) q <= d;
  end
endmodule

// -------------------------------------------
// 16-bit signed saturation adder (2's comp.)
// out = sat(a + b)
// -------------------------------------------
module sat_add16 (
  input  wire signed [15:0] a,
  input  wire signed [15:0] b,
  output reg  signed [15:0] y
);
  wire signed [16:0] sum17 = {a[15],a} + {b[15],b};  // extend to detect overflow

  always @* begin
    // Overflow if top two bits differ
    if ( sum17[16] != sum17[15] ) begin
      // Positive overflow ? clamp to +32767 (0x7FFF)
      y = sum17[16] ? 16'sh8000 : 16'sh7FFF; // if negative overflow, min; else max
    end else begin
      y = sum17[15:0];
    end
  end
endmodule
