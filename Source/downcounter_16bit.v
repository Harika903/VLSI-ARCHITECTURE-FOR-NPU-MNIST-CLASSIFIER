module downcounter_16bit (
    input  wire        clk,
    input  wire        rst,

    // Control inputs
    input  wire        load,       // Load counter with start value
    input  wire        en_cnt,      // Enable counting (ACC state)
    input  wire [15:0] load_value, // Programmable accumulation count

    // Output
    output reg         CTR_OUT      // Asserted when counter reaches zero
);

    reg [15:0] count;

    // -------------------------------------------------
    // Counter logic
    // -------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count   <= 16'd0;
            CTR_OUT <= 1'b0;
        end
        else if (load) begin
            count   <= load_value;
            CTR_OUT <= 1'b0;
        end
        else if (en_cnt) begin
            if (count > 16'd1) begin
                count   <= count - 16'd1;
                CTR_OUT <= 1'b0;
            end
            else begin
                count   <= 16'd0;
                CTR_OUT <= 1'b1;   // Counter done
            end
        end
    end

endmodule
