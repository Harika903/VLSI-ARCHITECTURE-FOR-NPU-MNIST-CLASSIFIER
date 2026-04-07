module fsm_out (
    input  wire clk,
    input  wire rst,

    // Control inputs
    input  wire EN_OUT,     // from FSM_ACC
    input  wire EN_ReLU1,   // from SSFR
    input  wire EN_FIFO,    // from SSFR

    // Control outputs
    output reg  OUT_LATCH_EN,
    output reg  FIFO_WR_EN,
    output reg  DONE
);

    // -------------------------------------------------
    // State encoding
    // -------------------------------------------------
    localparam OUT_IDLE = 3'd0,
               OUT_S1   = 3'd1,
               OUT_S2   = 3'd2,
               OUT_S3   = 3'd3,
               OUT_S4   = 3'd4,
               OUT_S5   = 3'd5;

    reg [2:0] state, next_state;

    // -------------------------------------------------
    // State register
    // -------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= OUT_IDLE;
        else
            state <= next_state;
    end

    // -------------------------------------------------
    // Next-state logic
    // -------------------------------------------------
    always @(*) begin
        next_state = state;

        case (state)

            OUT_IDLE: begin
                if (EN_OUT && EN_ReLU1)
                    next_state = OUT_S1;
            end

            OUT_S1: next_state = OUT_S2;
            OUT_S2: next_state = OUT_S3;
            OUT_S3: next_state = OUT_S4;
            OUT_S4: next_state = OUT_S5;

            OUT_S5: next_state = OUT_IDLE;

            default: next_state = OUT_IDLE;

        endcase
    end

    // -------------------------------------------------
    // Registered DONE pulse (IMPORTANT FIX)
    // -------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst)
            DONE <= 1'b0;
        else if (state == OUT_S5)
            DONE <= 1'b1;     // 1 full clock pulse
        else
            DONE <= 1'b0;
    end

    // -------------------------------------------------
    // Output control signals (combinational OK)
    // -------------------------------------------------
    always @(*) begin
        OUT_LATCH_EN = 1'b0;
        FIFO_WR_EN   = 1'b0;

        case (state)

            OUT_S3,
            OUT_S4: begin
                OUT_LATCH_EN = 1'b1;
            end

            OUT_S5: begin
                if (EN_FIFO)
                    FIFO_WR_EN = 1'b1;
            end

        endcase
    end

endmodule
