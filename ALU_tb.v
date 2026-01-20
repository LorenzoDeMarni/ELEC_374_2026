`timescale 1ns/10ps
module ALU_tb;

	reg[7:0] input_a, input_b;
	reg[3:0] opcode;
	
	wire[7:0] ALU_result;
	
	ALU ALU_instance(input_a, input_b, opcode, ALU_result);
	
	initial
		begin
			input_a <= 2;
			input_b <= 3;
			opcode <= 0;
			
		#200 
			opcode <= 1;
		end
	
// VCD dump for GTKWave
initial begin
  $dumpfile("waveforms.vcd");
  $dumpvars;
end

initial begin
  #127500;
  $display("Simulation complete.");
  $finish;
end

endmodule

