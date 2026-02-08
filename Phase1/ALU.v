module ALU(input wire [31:0] A, B, input wire [3:0] op, output reg[63:0] result);
	
	
	wire [31:0] and_result, or_result, not_result, neg_result;
    wire [31:0] add_result, sub_result;
    wire [31:0] shift_left_result, shift_right_result, shift_right_arithmetic_result;
    wire [31:0] rotate_left_result, rotate_right_result;
    wire [63:0] mul_result;
    wire [31:0] div_quotient, div_remainder;
	
	and_or and_instance(A, B, 1, and_result);
	and_or or_instance(A, B, 0, or_result);

	assign not_result = ~A;
	assign neg_result = -A;

	assign shift_left_result = A << B[4:0];
	assign shift_right_result = A >> B[4:0];
	assign shift_right_arithmetic_result = $signed(A) >>> B[4:0];
	assign rotate_left_result = (A << B[4:0]) | (A >> (32 - B[4:0]));
	assign rotate_right_result = (A >> B[4:0]) | (A << (32 - B[4:0]));

	adder add_instance(A, B, add_result);
    
    wire [31:0] neg_B = -B;
    adder sub_instance(A, neg_B, sub_result);
    
    booth_multiplier mul_instance(A, B, mul_result);
    
    NRDivider div_instance(A, B, div_quotient, div_remainder);

	
	always @(*) begin
		case(op)
			0	:	result = or_result;
			1	:	result = and_result;
			2	:	result = not_result;
			3	:	result = {32'd0, add_result};
			4	:	result = {32'd0, sub_result};
			5	:	result = neg_result;
			6	:	result = mul_result;
			7	:	result = {div_remainder, div_quotient};
			8	:	result = shift_left_result;
			9	:	result = shift_right_result;
			10	:	result = shift_right_arithmetic_result;
			11	:	result = rotate_left_result;
			12	:	result = rotate_right_result;
			// ... 
			default: result = and_result;
		endcase
	end
	
endmodule
