// ------------------------------------------------------------------
// PISO: Load two 16b words, shift out as 4×8b (MSB-first by default)
// Sequence: W2[15:8], W2[7:0], W1[15:8], W1[7:0]
// Control: load then shift with en; 'done' pulses after 4 bytes
// ------------------------------------------------------------------
module piso_2x16_to_8 (
  input  wire        clk,
  input  wire        rst,
  input  wire        en,
  input  wire        load,
  input  wire [15:0] w1,
  input  wire [15:0] w2,
  output reg  [7:0]  dout,
  output reg         busy,
  output reg         done
);
  reg [1:0]  cnt;
  reg [31:0] shreg;

  always @(posedge clk) begin
    if (rst) begin
      cnt   <= 2'd0;
      shreg <= 32'd0;
      dout  <= 8'd0;
      busy  <= 1'b0;
      done  <= 1'b0;
    end else begin
      done <= 1'b0;
      if (load) begin
        // pack as W2_hi, W2_lo, W1_hi, W1_lo
        shreg <= {w2[15:8], w2[7:0], w1[15:8], w1[7:0]};
        cnt   <= 2'd0;
        busy  <= 1'b1;
      end else if (en && busy) begin
        dout <= shreg[31:24];
        shreg <= {shreg[23:0], 8'd0};
        cnt <= cnt + 2'd1;
        if (cnt == 2'd3) begin
          busy <= 1'b0;
          done <= 1'b1;
        end
      end
    end
  end
endmodule

