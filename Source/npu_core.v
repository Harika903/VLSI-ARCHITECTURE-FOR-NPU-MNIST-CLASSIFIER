// =====================================================
// NPU Core Top (minimal wiring example for 2 MAC lanes)
// =====================================================
module npu_core_top (
  input  wire         clk,
  input  wire         rst,

  // Inputs (4x8-bit channels)
  input  wire  [7:0]  DA, DB, DC, DD,

  // Controls
  input  wire         EN_BUF_IN,
  input  wire         EN_MAC,
  input  wire         RST_MAC,
  input  wire         SEL_BIAS1, SEL_BIAS2,   // per MAC
  input  wire         EN_ReLU,
  input  wire         BYPASS_ReLU1, BYPASS_ReLU2,
  input  wire         LATCH_RELU,            // stage enable
  input  wire         PISO_LOAD, PISO_EN,
  input  wire         FIFO_WR_EN, FIFO_RD_EN,
  input  wire  [2:0]  SEL_OUT,               // SSFR[15:13] style

  // Biases and weights/data select come from external control
  input  wire signed [15:0] BIAS1,
  input  wire signed [15:0] BIAS2,

  // Output
  output wire  [7:0]  D_OUT,
  output wire         FIFO_FULL,
  output wire         FIFO_EMPTY
);
  // ---------- Input Buffer ----------
  wire [7:0] DA_q, DB_q, DC_q, DD_q;
  input_buffer_4x8 u_inbuf (
    .clk(clk), .rst(rst), .en_buf(EN_BUF_IN),
    .DA(DA), .DB(DB), .DC(DC), .DD(DD),
    .DA_q(DA_q), .DB_q(DB_q), .DC_q(DC_q), .DD_q(DD_q)
  );

  // Example mapping (customize as per your datapath):
  // MAC1 uses DA_q (data) × DB_q (weight)
  // MAC2 uses DC_q (data) × DD_q (weight)

  // ---------- MACs ----------
  wire signed [15:0] mac1_out, mac2_out;

  mac_8x8_to_16 u_mac1 (
    .clk(clk), .rst(rst), .en_mac(EN_MAC), .rst_mac(RST_MAC),
    .a($signed(DA_q)), .b($signed(DB_q)),
    .bias(BIAS1), .sel_bias(SEL_BIAS1),
    .acc_out(mac1_out)
  );

  mac_8x8_to_16 u_mac2 (
    .clk(clk), .rst(rst), .en_mac(EN_MAC), .rst_mac(RST_MAC),
    .a($signed(DC_q)), .b($signed(DD_q)),
    .bias(BIAS2), .sel_bias(SEL_BIAS2),
    .acc_out(mac2_out)
  );

  // ---------- ReLUs ----------
  wire signed [15:0] relu1_out, relu2_out;

  relu16 u_relu1 (
    .clk(clk), .rst(rst),
    .EN_ReLU(EN_ReLU), .BYPASS_ReLU(BYPASS_ReLU1),
    .x_in(mac1_out), .x_out(relu1_out)
  );

  relu16 u_relu2 (
    .clk(clk), .rst(rst),
    .EN_ReLU(EN_ReLU), .BYPASS_ReLU(BYPASS_ReLU2),
    .x_in(mac2_out), .x_out(relu2_out)
  );

  // ---------- Latch stage (4 DFFs of 8-bit) ----------
  wire [7:0] r1_hi, r1_lo, r2_hi, r2_lo;
  relu_stage_latch u_latch (
    .clk(clk), .rst(rst), .en(LATCH_RELU),
    .relu1(relu1_out), .relu2(relu2_out),
    .r1_hi(r1_hi), .r1_lo(r1_lo), .r2_hi(r2_hi), .r2_lo(r2_lo)
  );

  // ---------- Auto Comparator ----------
  wire signed [15:0] max_val;
  wire [7:0]         max_idx;
  auto_comparator2 u_comp (
    .clk(clk), .rst(rst), .en(LATCH_RELU),
    .a(relu1_out), .b(relu2_out),
    .max_val(max_val), .max_idx(max_idx)
  );

  // ---------- PISO (main data path: two 16-bit words) ----------
  wire [7:0] piso_out;
  wire       piso_busy, piso_done;
  piso_2x16_to_8 u_piso (
    .clk(clk), .rst(rst), .en(PISO_EN), .load(PISO_LOAD),
    .w1(relu1_out), .w2(relu2_out),
    .dout(piso_out), .busy(piso_busy), .done(piso_done)
  );

  // ---------- FIFO (serialize bytes from PISO to store) ----------
  wire [7:0] fifo_dout;
  fifo_sync8 #(.DEPTH(128)) u_fifo (
    .clk(clk), .rst(rst),
    .wr_en(FIFO_WR_EN), .rd_en(FIFO_RD_EN),
    .din(piso_out), .dout(fifo_dout),
    .full(FIFO_FULL), .empty(FIFO_EMPTY)
  );

  // ---------- Debug PISO (example: expose internal bytes) ----------
  //wire [7:0] debug_out;
  //wire       dbg_busy;
  //wire [31:0] debug_bus = {r1_hi, r1_lo, r2_hi, r2_lo};
  //piso_debug32 u_dbg (
    //.clk(clk), .rst(rst),
    //.en(PISO_EN), .load(PISO_LOAD),
    //.dbg_bus(debug_bus),
    //.dout(debug_out),
   // .busy(dbg_busy)
 // );

  // ---------- Output MUX ----------
  wire [7:0] direct_out;
  
  // take lower 8 bits of accumulated value
  assign direct_out = relu1_out[7:0];
  
 // output_mux u_outmux (
 //     .sel(SEL_OUT),
   //   .fifo_out(direct_out),   // <<< OVERRIDE FIFO path
   //   .piso_out(piso_out),
 //     .comp_index(max_idx),
 //     .debug_out(8'h00),
  //    .D_OUT(D_OUT)
 // );
// Direct output for numerical validation
 assign D_OUT = relu1_out[7:0];


endmodule

