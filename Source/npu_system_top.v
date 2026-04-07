(* keep_hierarchy = "yes" *)
module npu_system_top (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,

    // SSFR write interface (host side)
    input  wire        wr_en,
    input  wire [3:0]  wr_addr,
    input  wire        wr_data,

    // NPU inputs
    input  wire [7:0]  DA,
    input  wire [7:0]  DB,
    input  wire [7:0]  DC,
    input  wire [7:0]  DD,

    // Outputs
    output wire        done,
    output wire [7:0]  D_OUT
);

    // -------------------------------------------------
    // SSFR outputs
    // -------------------------------------------------
    wire [2:0] SEL_OUT;
    wire       BYPASS_ReLU1;
    wire       BYPASS_ReLU2;
    wire       EN_COMP;
    wire       RST_COMP;
    wire       EN_FIFO;
    wire       RST_FIFO;
    wire [6:0] ACC_COUNT;

    // -------------------------------------------------
    // FSM_ACC <-> FSM_OUT handshake
    // -------------------------------------------------
    wire ACC_EN;
    wire BIAS_EN;
    wire LAST_EN;
    wire OUT_DONE_ACC;
    wire OUT_DONE_OUT;

    // -------------------------------------------------
    // Counter signals
    // -------------------------------------------------
    wire CTR_OUT;

    // -------------------------------------------------
    // FSM_OUT control
    // -------------------------------------------------
    wire OUT_LATCH_EN;
    wire FIFO_WR_EN;
    wire fifo_empty;
    wire fifo_full;
    wire fifo_rd_en;
    
    assign fifo_rd_en = ~fifo_empty;


    // -------------------------------------------------
    // SSFR
    // -------------------------------------------------
    ssfr u_ssfr (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),

        .SEL_OUT(SEL_OUT),
        .BYPASS_ReLU1(BYPASS_ReLU1),
        .BYPASS_ReLU2(BYPASS_ReLU2),
        .EN_COMP(EN_COMP),
        .RST_COMP(RST_COMP),
        .EN_FIFO(EN_FIFO),
        .RST_FIFO(RST_FIFO),
        .ACC_COUNT(ACC_COUNT),

        .SSFR_OUT()
    );

    // -------------------------------------------------
    // 16-bit Down Counter (Programmable)
    // -------------------------------------------------
    wire [15:0] acc_load_val;

    assign acc_load_val =
        (ACC_COUNT == 7'd0) ? 16'd1 : {9'd0, ACC_COUNT};

    downcounter_16bit u_ctr (
        .clk(clk),
        .rst(rst),
        .load(start),
        .en_cnt(ACC_EN),
        .load_value(acc_load_val),
        .CTR_OUT(CTR_OUT)
    );

    // -------------------------------------------------
    // FSM_ACC
    // -------------------------------------------------
    fsm_acc u_fsm_acc (
        .clk(clk),
        .rst(rst),

        .EN_FSM(EN_COMP),
        .CTR_OUT(CTR_OUT),
        .OUT_DONE_FB(OUT_DONE_OUT),

        .ACC_EN(ACC_EN),
        .BIAS_EN(BIAS_EN),
        .LAST_EN(LAST_EN),
        .OUT_DONE(OUT_DONE_ACC)
    );

    // -------------------------------------------------
    // FSM_OUT
    // -------------------------------------------------
    fsm_out u_fsm_out (
        .clk(clk),
        .rst(rst),

        .EN_OUT(OUT_DONE_ACC),
        .EN_ReLU1(~BYPASS_ReLU1),
        .EN_FIFO(EN_FIFO),

        .OUT_LATCH_EN(OUT_LATCH_EN),
        .FIFO_WR_EN(FIFO_WR_EN),
        .DONE(OUT_DONE_OUT)
    );

    // -------------------------------------------------
    // DONE signal latch
    // -------------------------------------------------
    reg done_r;

    always @(posedge clk or posedge rst) begin
        if (rst)
            done_r <= 1'b0;
        else
            done_r <= OUT_DONE_OUT;
    end

    assign done = done_r;

    // -------------------------------------------------
    // NPU Core
    // -------------------------------------------------
    npu_core_top u_npu (
        .clk(clk),
        .rst(rst | RST_COMP),
    
        .DA(DA),
        .DB(DB),
        .DC(DC),
        .DD(DD),
    
        .EN_BUF_IN(ACC_EN),
        .EN_MAC(ACC_EN),
        .RST_MAC(rst),


    
        .SEL_BIAS1(1'b0),
        .SEL_BIAS2(1'b0),
    
        .EN_ReLU(~BYPASS_ReLU1),
        .BYPASS_ReLU1(BYPASS_ReLU1),
        .BYPASS_ReLU2(BYPASS_ReLU2),
    
        .LATCH_RELU(OUT_LATCH_EN),
    
        .PISO_LOAD(OUT_LATCH_EN),
        .PISO_EN(1'b1),
    
        .FIFO_WR_EN(FIFO_WR_EN),
        .FIFO_RD_EN(fifo_rd_en),
    
        .SEL_OUT(SEL_OUT),
    
        .BIAS1(16'd0),
        .BIAS2(16'd0),
    
        .D_OUT(D_OUT),
        .FIFO_FULL(fifo_full),
        .FIFO_EMPTY(fifo_empty)
    );


endmodule
