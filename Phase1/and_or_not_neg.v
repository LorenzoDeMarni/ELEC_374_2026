module andFunction(input wire [31:0] A, B, output wire [31:0] result);
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : and_loop
            assign result[i] = A[i] & B[i];
        end
    endgenerate
endmodule


module orFunction(input wire [31:0] A, B, output wire [31:0] result);
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : or_loop
            assign result[i] = A[i] | B[i];
        end
    endgenerate
endmodule


module notFunction(input wire [31:0] A, output reg [31:0] result);
    integer i;
	always @(*) begin
		for (i = 0; i < 32; i = i + 1) begin
			result[i] = !A[i]; // procedural NOT
		end
	end
endmodule


module negFunction(
    input wire [31:0] A,
    output reg [31:0] result
);
    reg [31:0] invertedA;
    wire [31:0] sum;
    wire [31:0] one;

    assign one = 32'b1;

    // invert A using a loop
    integer i;
    always @(*) begin
        for (i = 0; i < 32; i = i + 1) begin
            invertedA[i] = ~A[i]; // or use !A[i] carefully
        end
    end

    // adder uses invertedA
    adder adder_instance(
        .A(invertedA),
        .B(one),
        .Result(sum)
    );

    // assign sum to result inside an always block
    always @(*) begin
        result = sum;
    end
endmodule
