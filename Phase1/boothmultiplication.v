module booth_multiplier (
    input  signed [31:0] multiplicand,
    input  signed [31:0] multiplier,
    output signed [63:0] product
);

    integer i;
    reg signed [63:0] A;
    reg signed [63:0] M;
    reg signed [33:0] Q; // multiplier + extra bit

    always @(*) begin
        A = 64'sd0;
        M = {{32{multiplicand[31]}}, multiplicand};
        Q = {multiplier, 1'b0};

        for (i = 0; i < 16; i = i + 1) begin
            case (Q[2:0])
                3'b001,
                3'b010: A = A + M;
                3'b011: A = A + (M << 1);
                3'b100: A = A - (M << 1);
                3'b101,
                3'b110: A = A - M;
                default: ;
            endcase

            // Arithmetic right shift by 2
            Q = {A[1:0], Q[33:2]};
            A = {A[63], A[63], A[63:2]};
        end
    end

    assign product = A;

endmodule
