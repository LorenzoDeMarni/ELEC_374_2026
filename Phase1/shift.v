module shiftLeft(input wire [31:0] A, input wire [4:0] shift_amount, output reg [31:0] result);
    integer i;
    always @(*) begin
        for (i = 0; i < 32; i = i + 1) begin
            if (i < shift_amount)
                result[i] = 1'b0;
            else
                result[i] = A[i - shift_amount];
        end
    end
endmodule


module shiftRight(input wire [31:0] A, input wire [4:0] shift_amount, output reg [31:0] result);
    integer i;
    always @(*) begin
        for (i = 0; i < 32; i = i + 1) begin
            if (i + shift_amount >= 32)
                result[i] = 1'b0;
            else
                result[i] = A[i + shift_amount];
        end
    end
endmodule


module shiftRightArithmetic(input wire [31:0] A, input wire [4:0] shift_amount, output reg [31:0] result);
    integer i;
    always @(*) begin
        for (i = 0; i < 32; i = i + 1) begin
            if (i + shift_amount >= 32)
                result[i] = A[31]; // sign bit
            else
                result[i] = A[i + shift_amount];
        end
    end
endmodule


module rotateLeft(
    input wire [31:0] A, 
    input wire [4:0] shift_amount, 
    output wire [31:0] result
);
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : rotl_loop
            // Calculate rotated index
            assign result[i] = A[(i - shift_amount + 32) % 32];
        end
    endgenerate
endmodule


module rotateRight(
    input wire [31:0] A, 
    input wire [4:0] shift_amount, 
    output wire [31:0] result
);
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : rotr_loop
            // Calculate rotated index
            assign result[i] = A[(i + shift_amount) % 32];
        end
    endgenerate
endmodule