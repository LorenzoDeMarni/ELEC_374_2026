module booth_multiplier (
    input  signed [31:0] multiplicand,
    input  signed [31:0] multiplier,
    output signed [63:0] product
);

    integer i;
    reg signed [64:0] temp_P; // 65-bit register to handle A, Q, and extra bit

    always @(*) begin
        // Initialize: Upper 32 bits 0, lower bits multiplier, extra bit 0
        temp_P = {32'd0, multiplier, 1'b0}; 

        for (i = 0; i < 32; i = i + 1) begin
            case (temp_P[1:0])
                2'b01: temp_P[64:33] = temp_P[64:33] + multiplicand;
                2'b10: temp_P[64:33] = temp_P[64:33] - multiplicand;
                default: ;
            endcase
            // Arithmetic Right Shift
            temp_P = {temp_P[64], temp_P[64:1]};
        end
    end

    // Assign the result (excluding the extra bit at bit 0)
    assign product = temp_P[64:1]; 

endmodule