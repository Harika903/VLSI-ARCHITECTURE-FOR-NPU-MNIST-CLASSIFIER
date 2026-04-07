module ssfr (
    input  wire        clk,
    input  wire        rst,

    // Write interface
    input  wire        wr_en,
    input  wire [3:0]  wr_addr,   // 0-15
    input  wire        wr_data,   // 1-bit

    // SSFR control outputs
    output wire [2:0]  SEL_OUT,
    output wire        BYPASS_ReLU1,
    output wire        BYPASS_ReLU2,
    output wire        EN_COMP,
    output wire        RST_COMP,
    output wire        EN_FIFO,
    output wire        RST_FIFO,

    // NEW: Programmable accumulation count
    output wire [6:0]  ACC_COUNT,

    // Full register visibility
    output wire [15:0] SSFR_OUT
);

    reg [15:0] ssfr;

    // -------------------------
    // Reset + Write logic
    // -------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ssfr[15:8] <= 8'b0010_0010;  // from PDF
            ssfr[7:0]  <= 8'b1000_0000;  // from PDF
        end
        else if (wr_en) begin
            ssfr[wr_addr] <= wr_data;
        end
    end

    // -------------------------
    // Control field assignments
    // -------------------------
    assign SEL_OUT       = ssfr[15:13];
    assign BYPASS_ReLU1  = ssfr[12];
    assign BYPASS_ReLU2  = ssfr[11];
    assign EN_COMP       = ssfr[10];
    assign RST_COMP      = ssfr[9];
    assign EN_FIFO       = ssfr[8];
    assign RST_FIFO      = ssfr[7];

    // -------------------------
    // NEW: Accumulation count
    // Uses SSFR[6:0]
    // -------------------------
    assign ACC_COUNT = ssfr[6:0];

    // -------------------------
    // Full register output
    // -------------------------
    assign SSFR_OUT = ssfr;

endmodule
