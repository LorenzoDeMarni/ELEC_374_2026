module andFunction(input wire [31:0] A, B, output reg [31:0] result);
    integer i;
    always @(*) begin
        for (i = 0; i < 32; i = i + 1) begin
            if (A[i] == 1'b1 && B[i] == 1'b1)
                result[i] = 1'b1;
            else
                result[i] = 1'b0;
        end
    end
endmodule


module orFunction(input wire [31:0] A, B, output reg [31:0] result);
    integer i;
    always @(*) begin
        for (i = 0; i < 32; i = i + 1) begin
            if (A[i] == 1'b1 || B[i] == 1'b1)
                result[i] = 1'b1;
            else
                result[i] = 1'b0;
        end
    end
endmodule


module notFunction(input wire [31:0] A, output reg [31:0] result);
    integer i;
    always @(*) begin
        for (i = 0; i < 32; i = i + 1) begin
            if (A[i] == 1'b1)
                result[i] = 1'b0;
            else
                result[i] = 1'b1;
        end
    end
endmodule


module negFunction(input wire [31:0] A, output wire [31:0] result);
    reg  [31:0] invertedA;
    wire [31:0] one;

    assign one = 32'b00000000000000000000000000000001;

    integer i;
    always @(*) begin
        for (i = 0; i < 32; i = i + 1) begin
            if (A[i] == 1'b1)
                invertedA[i] = 1'b0;
            else
                invertedA[i] = 1'b1;
        end
    end

    // adder output drives result → result must be wire
    adder adder_instance(invertedA, one, result);
endmodule


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


module rotateLeft(input wire [31:0] A, input wire [4:0] shift_amount, output reg [31:0] result);
    integer i;
    integer src;
    always @(*) begin
        for (i = 0; i < 32; i = i + 1) begin
            src = i - shift_amount;
            if (src < 0)
                src = src + 32;
            result[i] = A[src];
        end
    end
endmodule


module rotateRight(input wire [31:0] A, input wire [4:0] shift_amount, output reg [31:0] result);
    integer i;
    integer src;
    always @(*) begin
        for (i = 0; i < 32; i = i + 1) begin
            src = i + shift_amount;
            if (src >= 32)
                src = src - 32;
            result[i] = A[src];
        end
    end
endmodule