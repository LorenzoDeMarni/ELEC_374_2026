module booth_multiplier (
    input  signed [31:0] multiplicand,
    input  signed [31:0] multiplier,
    output signed [63:0] product
);

    integer i; //loop counter variable

    reg signed [64:0] temp_P; // 65-bit register to handle A, Q, and extra bit (need 65 bits to hold the extra bit for Booth's algorithm (default 0))

    always @(*) begin
        // Initialize: Upper 32 bits 0, lower bits multiplier, extra bit 0
        temp_P = {32'd0, multiplier, 1'b0}; 

        //Loop for 32 iterations (since we are multiplying 32-bit numbers)
        for (i = 0; i < 32; i = i + 1) begin

            //Per Booth Algorithm, Run Table (Seen Below) and add multiplier of 0, 1, or -1 to the multiplicand based on the last two bits of temp_P (Q0 and Q-1 (why we need the extra bit when it starts out))
            case (temp_P[1:0]) //Check if either 01 or 10 (If neither do nothing since multiplying by 0 does nothing)
                2'b01: temp_P[64:33] = temp_P[64:33] + multiplicand; //If 01, effectively add multiplicand to upper half (A) (Done on the upper half so least significant bit preserved after right shift)
                2'b10: temp_P[64:33] = temp_P[64:33] - multiplicand; //If 10, effectively subtract multiplicand from upper half (A)
                default: ;
            endcase
            // Arithmetic Right Shift
            temp_P = {temp_P[64], temp_P[64:1]}; //Preserves sign and bits 64 down to 1, discards bit 0 (Q-1) and shifts in the sign bit at the leftmost position
        end
    end

    // Assign the result (excluding the extra bit at bit 0)
    assign product = temp_P[64:1]; 

endmodule

//Q Q-1 | Action
// 0 0  | x0
// 0 1  | x1
// 1 0  | x-1
// 1 1  | x0