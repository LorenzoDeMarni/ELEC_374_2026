module ALU(input wire [7:0] A, B, input wire [3:0] op, output reg[7:0] result);
	
	
	wire [7:0] and_result, or_result, not_result;
	
	and_or and_instance(A, B, 1, and_result);
	and_or or_instance(A, B, 0, or_result);
	assign not_result = ~A;
	
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
