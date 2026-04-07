// ------------------------------------------------------
// Output MUX
// 000: FIFO
// 001: PISO main
// 010: Comparator index
// 011: Debug PISO
// others: zeros (reserve)
// ------------------------------------------------------
module output_mux (
  input  wire [2:0] sel,
  input  wire [7:0] fifo_out,
  input  wire [7:0] piso_out,
  input  wire [7:0] comp_index,   // use max_idx[7:0]
  input  wire [7:0] debug_out,
  output reg  [7:0] D_OUT
);
  always @* begin
    case (sel)
      3'b000: D_OUT = fifo_out;
      3'b001: D_OUT = piso_out;
      3'b010: D_OUT = comp_index;
      3'b011: D_OUT = debug_out;
      default: D_OUT = 8'd0;
    endcase
  end
endmodule
