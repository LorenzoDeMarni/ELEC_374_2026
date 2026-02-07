`timescale 1ns/10ps
module ALU_tb;

  reg [31:0] input_a, input_b;
  reg [3:0] opcode;
  wire [31:0] ALU_result;

  ALU ALU_instance(input_a, input_b, opcode, ALU_result);

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars;
    
    // Test values
    input_a = 32'd20;
    input_b = 32'd5;
    
    // Test each operation
    opcode = 0; #20;  // OR: 20 | 5 = 21
    $display("OR:   A=%d, B=%d, Result=%d (expected 21)", input_a, input_b, ALU_result);
    
    opcode = 1; #20;  // AND: 20 & 5 = 4
    $display("AND:  A=%d, B=%d, Result=%d (expected 4)", input_a, input_b, ALU_result);
    
    opcode = 2; #20;  // NOT: ~20 = 235
    $display("NOT:  A=%d, Result=%d (expected 235)", input_a, ALU_result);
    
    opcode = 3; #20;  // ADD: 20 + 5 = 25
    $display("ADD:  A=%d, B=%d, Result=%d (expected 25)", input_a, input_b, ALU_result);
    
    opcode = 4; #20;  // SUB: 20 - 5 = 15
    $display("SUB:  A=%d, B=%d, Result=%d (expected 15)", input_a, input_b, ALU_result);
    
    opcode = 5; #20;  // NEG: -20 = 236 (in 8-bit unsigned)
    $display("NEG:  A=%d, Result=%d (expected 236)", input_a, ALU_result);
    
    opcode = 7; #20;  // DIV: 20 / 5 = 4
    $display("DIV:  A=%d, B=%d, Result=%d (expected 4)", input_a, input_b, ALU_result);
    
    // Test shifts and rotates
    input_a = 32'b10110010;  // 178
    input_b = 32'd2;         // Shift amount
    
    opcode = 8; #20;  // SHL: 10110010 << 2 = 11001000 (200)
    $display("SHL:  A=%b, B=%d, Result=%b (expected 11001000)", input_a, input_b, ALU_result);
    
    opcode = 9; #20;  // SHR: 10110010 >> 2 = 00101100 (44)
    $display("SHR:  A=%b, B=%d, Result=%b (expected 00101100)", input_a, input_b, ALU_result);
    
    opcode = 11; #20; // ROL: rotate left by 2
    $display("ROL:  A=%b, B=%d, Result=%b", input_a, input_b, ALU_result);
    
    opcode = 12; #20; // ROR: rotate right by 2
    $display("ROR:  A=%b, B=%d, Result=%b", input_a, input_b, ALU_result);
    
    $display("\n=== All tests complete ===");
    #20 $finish;
  end

endmodule
