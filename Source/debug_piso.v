// -------------------------------------------
// Simple 8-bit synchronous FIFO, depth power-of-2
// -------------------------------------------
module fifo_sync8 #(parameter DEPTH=128, parameter AW=$clog2(DEPTH))(
  input  wire       clk,
  input  wire       rst,
  input  wire       wr_en,
  input  wire       rd_en,
  input  wire [7:0] din,
  output reg  [7:0] dout,
  output wire       full,
  output wire       empty
);
  reg [7:0] mem [0:DEPTH-1];
  reg [AW:0] wptr, rptr; // extra bit to detect full/empty

  assign empty = (wptr == rptr);
  assign full  = ( (wptr[AW] != rptr[AW]) && (wptr[AW-1:0] == rptr[AW-1:0]) );

  always @(posedge clk) begin
    if (rst) begin
      wptr <= 0; rptr <= 0; dout <= 8'd0;
    end else begin
      if (wr_en && !full) begin
        mem[wptr[AW-1:0]] <= din;
        wptr <= wptr + 1'b1;
      end
      if (rd_en && !empty) begin
        dout <= mem[rptr[AW-1:0]];
        rptr <= rptr + 1'b1;
      end
    end
  end
endmodule
