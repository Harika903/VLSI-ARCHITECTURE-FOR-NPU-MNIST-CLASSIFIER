module npu_fsm (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire fifo_full,

    input  wire EN_COMP,   // from SSFR

    output reg  EN_BUF_IN,
    output reg  EN_MAC,
    output reg  EN_ReLU,
    output reg  LATCH_RELU,
    output reg  FIFO_WR_EN,
    output reg  done
);

    localparam IDLE    = 3'd0,
               LOAD    = 3'd1,
               COMPUTE = 3'd2,
               STORE   = 3'd3,
               DONE    = 3'd4;

    reg [2:0] current_state, next_state;

    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE:    if (start && EN_COMP) next_state = LOAD;
            LOAD:                     next_state = COMPUTE;
            COMPUTE:                  next_state = STORE;
            STORE:   if (!fifo_full) next_state = DONE;
            DONE:                     next_state = IDLE;
        endcase
    end

    always @(*) begin
        EN_BUF_IN   = 0;
        EN_MAC      = 0;
        EN_ReLU     = 0;
        LATCH_RELU  = 0;
        FIFO_WR_EN  = 0;
        done        = 0;

        case (current_state)
            LOAD:    EN_BUF_IN = 1;
            COMPUTE: begin EN_MAC = 1; EN_ReLU = 1; end
            STORE:   begin LATCH_RELU = 1; FIFO_WR_EN = 1; end
            DONE:    done = 1;
        endcase
    end

endmodule


