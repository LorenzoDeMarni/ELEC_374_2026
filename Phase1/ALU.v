module ALU(
    input wire [31:0] A, B,
    input wire AND, OR, NOT, NEG,
    input wire ADD, SUB, MUL, DIV,
    input wire SHR, SHRA, SHL, ROR, ROL,
    output reg [63:0] result
);
	
	wire [31:0] and_result, or_result, not_result, add_result, sub_result, neg_result;
	wire [31:0] shift_left_result, shift_right_result, shift_right_arithmetic_result;
	wire [31:0] rotate_left_result, rotate_right_result;
	wire [63:0] mul_result;  // 64-bit for MUL!
	wire [31:0] neg_B;
	
	// Basic operations
	assign and_result = A & B;
	assign or_result = A | B;
	assign not_result = ~A;
	assign neg_result = -A;
	
	// Shifts and rotates (use B[4:0] for 32-bit shift amounts)
	assign shift_left_result = A << B[4:0];
	assign shift_right_result = A >> B[4:0];
	assign shift_right_arithmetic_result = $signed(A) >>> B[4:0];
	assign rotate_left_result = (A << B[4:0]) | (A >> (32 - B[4:0]));
	assign rotate_right_result = (A >> B[4:0]) | (A << (32 - B[4:0]));
	
	// ADD: use structural ripple-carry adder 
	adder add_instance(A, B, add_result);
	
	// SUB: A - B = A + (-B)
	assign neg_B = -B;
	adder sub_instance(A, neg_B, sub_result);
	
	// MUL: TODO - implement Booth/CSA multiplier
	assign mul_result = 64'd0;  // 64-bit placeholder
	
	// DIV: use non-restoring divider
	wire [31:0] div_quotient, div_remainder;
	NRDivider divider_instance(A, B, div_quotient, div_remainder);
	
	always @(*) begin
		if (AND)
			result = {32'd0, and_result};
		else if (OR)
			result = {32'd0, or_result};
		else if (NOT)
			result = {32'd0, not_result};
		else if (ADD)
			result = {32'd0, add_result};
		else if (SUB)
			result = {32'd0, sub_result};
		else if (MUL)
			result = mul_result;  // Full 64-bit
		else if (DIV)
			result = {div_remainder, div_quotient};  // Upper: remainder, Lower: quotient
		else if (NEG)
			result = {32'd0, neg_result};
		else if (SHR)
			result = {32'd0, shift_right_result};
		else if (SHRA)
			result = {32'd0, shift_right_arithmetic_result};
		else if (SHL)
			result = {32'd0, shift_left_result};
		else if (ROR)
			result = {32'd0, rotate_right_result};
		else if (ROL)
			result = {32'd0, rotate_left_result};
		else
			result = 64'd0;
	end
	
endmodule