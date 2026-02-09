module and_or(input wire [31:0] A, B, input wire selection, output wire [31:0] result);

	assign result = (selection == 1)? A & B : A | B;
	
endmodule
