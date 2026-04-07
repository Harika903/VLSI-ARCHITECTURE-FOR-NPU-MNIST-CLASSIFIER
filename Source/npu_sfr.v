module npu_sfr (
    input  wire        clk,
    input  wire        rst,

    // Write interface (from TB / CPU model)
    input  wire        wr_en,
    input  wire [3:0]  addr,
    input  wire [31:0] wr_data,

    // Status inputs (from NPU)
    input  wire        done,
    input  wire        fifo_full,
    input  wire        fifo_empty,

    // Control outputs (to FSM / NPU)
    output reg         START,
    output reg         EN_ReLU,
    output reg         BYPASS_ReLU,
    output reg  [2:0]  SEL_OUT
);

    // Registers
    reg [31:0] CTRL_REG;
    reg [31:0] STATUS_REG;
    reg [31:0] OUTSEL_REG;

    // -------------------------
    // Write logic
    // -------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            CTRL_REG   <= 32'd0;
            OUTSEL_REG <= 32'd0;
        end else if (wr_en) begin
            case (addr)
                4'h0: CTRL_REG   <= wr_data;   // Control
                4'h8: OUTSEL_REG <= wr_data;   // Output select
            endcase
        end
    end

    // -------------------------
    // Status register (read-only)
    // -------------------------
    always @(*) begin
        STATUS_REG[0] = done;
        STATUS_REG[1] = fifo_full;
        STATUS_REG[2] = fifo_empty;
        STATUS_REG[31:3] = 0;
    end

    // -------------------------
    // Control signal decode
    // -------------------------
    always @(*) begin
        START        = CTRL_REG[0];
        EN_ReLU      = CTRL_REG[1];
        BYPASS_ReLU  = CTRL_REG[2];
        SEL_OUT      = OUTSEL_REG[2:0];
    end

endmodule
