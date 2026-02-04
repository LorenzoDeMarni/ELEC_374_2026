module ALU(input wire [7:0] A, B, input wire [3:0] op, output reg[7:0] result);
	
	
	wire [7:0] and_result, or_result, not_result, add_result, sub_result, neg_result;
	wire [7:0] shift_left_result, shift_right_result, shift_right_arithmetic_result;
	wire [7:0] rotate_left_result, rotate_right_result;
	wire [7:0] mul_result, div_result;
	wire [7:0] neg_B;
	
	// Basic operations using Verilog operators (allowed)
	assign and_result = A & B;
	assign or_result = A | B;
	assign not_result = ~A;
	assign neg_result = -A;
	
	// Shifts and rotates using Verilog operators (allowed)
	assign shift_left_result = A << B[2:0];
	assign shift_right_result = A >> B[2:0];
	assign shift_right_arithmetic_result = $signed(A) >>> B[2:0];
	assign rotate_left_result = (A << B[2:0]) | (A >> (8 - B[2:0]));
	assign rotate_right_result = (A >> B[2:0]) | (A << (8 - B[2:0]));
	
	// ADD: use structural ripple-carry adder 
	adder add_instance(A, B, add_result);
	
	// SUB: A - B = A + (-B), use adder 
	assign neg_B = -B;  // Two's complement of B
	adder sub_instance(A, neg_B, sub_result);
	
	// MUL: TODO - implement Booth/CSA multiplier
	assign mul_result = 8'd0;  // Placeholder
	
	// DIV: use non-restoring divider
	wire [7:0] div_quotient, div_remainder;
	NRDivider divider_instance(A, B, div_quotient, div_remainder);
	assign div_result = div_quotient;
	
	always @(*) begin
		case(op)
			0	:	result = or_result;
			1	:	result = and_result;
			2	:	result = not_result;
			3	:	result = add_result; 
			4	:	result = sub_result; 
			5	:	result = neg_result;
			6	:	result = mul_result;
			7	:	result = div_result;
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
