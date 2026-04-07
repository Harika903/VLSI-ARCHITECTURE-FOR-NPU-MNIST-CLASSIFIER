module fsm_acc (
    input  wire clk,
    input  wire rst,

    // Control inputs (from SSFR / datapath)
    input  wire EN_FSM,        // EN_COMP from SSFR
    input  wire CTR_OUT,       // accumulator counter done
    input  wire OUT_DONE_FB,   // from FSM_OUT

    // Control outputs
    output reg  ACC_EN,
    output reg  BIAS_EN,
    output reg  LAST_EN,
    output reg  OUT_DONE
);

    // -------------------------------------------------
    // State encoding
    // -------------------------------------------------
    localparam IDLE = 3'd0,
               BIAS = 3'd1,
               ACC  = 3'd2,
               LAST = 3'd3,
               WAIT = 3'd4;

    reg [2:0] state, next_state;

    // -------------------------------------------------
    // State register
    // -------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // -------------------------------------------------
    // Next-state logic (PDF exact)
    // -------------------------------------------------
    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (EN_FSM)
                    next_state = BIAS;
            end

            BIAS: begin
                next_state = ACC;
            end

            ACC: begin
                if (CTR_OUT)
                    next_state = LAST;
                else
                    next_state = ACC;
            end

            LAST: begin
                next_state = WAIT;
            end

            WAIT: begin
                if (OUT_DONE_FB)
                    next_state = IDLE;
                else
                    next_state = WAIT;
            end

            default: next_state = IDLE;
        endcase
    end

    // -------------------------------------------------
    // Output logic
    // -------------------------------------------------
    always @(*) begin
        ACC_EN   = 1'b0;
        BIAS_EN = 1'b0;
        LAST_EN = 1'b0;
        OUT_DONE = 1'b0;

        case (state)
            BIAS: begin
                BIAS_EN = 1'b1;
            end

            ACC: begin
                ACC_EN = 1'b1;
            end

            LAST: begin
                LAST_EN = 1'b1;
                OUT_DONE = 1'b1;
            end
        endcase
    end

endmodule

