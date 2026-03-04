module ALU(
    input wire [31:0] A, B,
    input wire opAND, opOR, opNOT, opNEG,
    input wire opADD, opSUB, opMUL, opDIV,
    input wire opSHR, opSHRA, opSHL, opROR, opROL,
    output reg [63:0] result
);
	
	wire [31:0] and_result, or_result, not_result, add_result, sub_result, neg_result;
	wire [31:0] shift_left_result, shift_right_result, shift_right_arithmetic_result;
	wire [31:0] rotate_left_result, rotate_right_result;
	wire [63:0] mul_result;  // 64-bit for MUL!
	wire [31:0] neg_B;
	
	// Basic operations
	andFunction andInstance(A, B, and_result);
	orFunction orInstance(A, B, or_result);
	notFunction notInstance(A, not_result);
	negFunction negInstance(B, neg_result);
	
	// Shifts and rotates (use B[4:0] for 32-bit shift amounts)
	shiftLeft shift_left_instance(A, B[4:0], shift_left_result);
	shiftRight shift_right_instance(A, B[4:0], shift_right_result);
	shiftRight shift_right_arithmetic_instance({A[31], A[31:1]}, B[4:0], shift_right_arithmetic_result);  // Arithmetic shift
	shiftLeft rotate_left_instance(A[31:0], B[4:0], rotate_left_result);  // Rotate left
	shiftRight rotate_right_instance(A[31:0], B[4:0], rotate_right_result);  // Rotate right

	adder add_instance(A, B, add_result);
  	adder sub_instance(A, neg_B, sub_result);
    
  	booth_multiplier mul_instance(A, B, mul_result);
    
	// DIV: use non-restoring divider
	wire [31:0] div_quotient, div_remainder;
    NRDivider div_instance(A, B, div_quotient, div_remainder);

	
	// SUB: A - B = A + (-B)
	assign neg_B = -B;
		
	
	always @(*) begin
		if (opAND)
			result = {32'd0, and_result};
		else if (opOR)
			result = {32'd0, or_result};
		else if (opNOT)
			result = {32'd0, not_result};
		else if (opADD)
			result = {32'd0, add_result};
		else if (opSUB)
			result = {32'd0, sub_result};
		else if (opMUL)
			result = mul_result;  // Full 64-bit
		else if (opDIV)
			result = {div_remainder, div_quotient};  // Upper: remainder, Lower: quotient
		else if (opNEG)
			result = {32'd0, neg_result};
		else if (opSHR)
			result = {32'd0, shift_right_result};
		else if (opSHRA)
			result = {32'd0, shift_right_arithmetic_result};
		else if (opSHL)
			result = {32'd0, shift_left_result};
		else if (opROR)
			result = {32'd0, rotate_right_result};
		else if (opROL)
			result = {32'd0, rotate_left_result};
		else
			result = 64'd0;
	end
	
endmodule