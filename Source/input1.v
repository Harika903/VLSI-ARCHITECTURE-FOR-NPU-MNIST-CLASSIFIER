// ----------------------------------------------------
// Input Buffer for DA, DB, DC, DD (each 8-bit, signed)
// ----------------------------------------------------
module input_buffer_4x8 (
  input  wire         clk,
  input  wire         rst,
  input  wire         en_buf,      // EN_BUF_IN
  input  wire  [7:0]  DA, DB, DC, DD,
  output wire  [7:0]  DA_q, DB_q, DC_q, DD_q
);
  dff #(.W(8)) ff_DA (.clk(clk), .rst(rst), .en(en_buf), .d(DA), .q(DA_q));
  dff #(.W(8)) ff_DB (.clk(clk), .rst(rst), .en(en_buf), .d(DB), .q(DB_q));
  dff #(.W(8)) ff_DC (.clk(clk), .rst(rst), .en(en_buf), .d(DC), .q(DC_q));
  dff #(.W(8)) ff_DD (.clk(clk), .rst(rst), .en(en_buf), .d(DD), .q(DD_q));
endmodule
