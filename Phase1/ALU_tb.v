`timescale 1ns/1ps
module ALU_tb;

  reg [31:0] input_a, input_b;
  reg opAND, opOR, opNOT, opNEG;
  reg opADD, opSUB, opMUL, opDIV;
  reg opSHR, opSHRA, opSHL, opROR, opROL;

  wire [63:0] ALU_result;

    ALU ALU_instance(
    .A(input_a),
    .B(input_b),
    .opAND(opAND),
    .opOR(opOR),
    .opNOT(opNOT),
    .opNEG(opNEG),
    .opADD(opADD),
    .opSUB(opSUB),
    .opMUL(opMUL),
    .opDIV(opDIV),
    .opSHR(opSHR),
    .opSHRA(opSHRA),
    .opSHL(opSHL),
    .opROR(opROR),
    .opROL(opROL),
    .result(ALU_result)
  );

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars;

    opAND=0; opOR=0; opNOT=0; opNEG=0;
    opADD=0; opSUB=0; opMUL=0; opDIV=0;
    opSHR=0; opSHRA=0; opSHL=0; opROR=0; opROL=0;
    
    // Test values
    input_a = -15;
    input_b = -4;
    
    // Test each operation
    $display("ALU_tb started");

    //Basic Operations
    opOR=1; #10;  // OR: 20 | 5 = 21
    $display("OR:   A=%0d, B=%0d, Result=%0d (expected 21)", input_a, input_b, ALU_result[31:0]);
    
    opOR=0; opAND=1; #5;  // AND: 20 & 5 = 4
    $display("AND:  A=%0d, B=%0d, Result=%0d (expected 4)", input_a, input_b, ALU_result[31:0]);
    
    opAND=0; opNOT=1; #5;  // NOT: ~20 = 235
    $display("NOT:  A=%0d, Result=%0d (expected -21)", input_a, $signed(ALU_result[31:0]));

    opNOT=0; opADD=1; #5;  // ADD: 20 + 5 = 25
    $display("ADD:  A=%0d, B=%0d, Result=%0d (expected 25)", input_a, input_b, ALU_result[31:0]);
    
    opADD=0; opSUB=1; #5;  // SUB: 20 - 5 = 15
    $display("SUB:  A=%0d, B=%0d, Result=%0d (expected 15)", input_a, input_b, ALU_result[31:0]);
    
    opSUB=0; opNEG=1; #5;  // NEG: -20 = 236 (in 8-bit unsigned)
    $display("NEG:  A=%0d, Result=%0d (expected -20)", input_a, $signed(ALU_result[31:0]));   

    opNEG=0; opMUL=1; #5;  // MUL: 20 * 5 = 100
    $display("MUL:  A=%0d, B=%0d, Result=%0d (expected 100)", input_a, input_b, ALU_result[31:0]);

    opMUL=0; opDIV=1; #5;  // DIV: 20 / 5 = 4
    $display("DIV:  A=%0d, B=%0d, Result=%0d (expected 4)", input_a, input_b, ALU_result[31:0]);
   
    // Test shifts and rotates
    input_a = 32'b10110010;  // 178
    input_b = 32'd2;         // Shift amount
    
    opDIV=0; opSHL=1; #5;  // SHL: 10110010 << 2 = 11001000 (200)
    $display("SHL:  A=%b, B=%0d, Result=%b (expected 11001000)", input_a, input_b, ALU_result[31:0]);
    
    opSHL=0; opSHR=1; #5;  // SHR: 10110010 >> 2 = 00101100 (44)
    $display("SHR:  A=%b, B=%0d, Result=%b (expected 00101100)", input_a, input_b, ALU_result[31:0]);
  
    input_a = 63'b10000100000000000000100010110010;  // 178
    input_b = 32'd2;         // Shift amount

    opSHR=0; opROL=1; #5; // ROL: rotate left by 2
    $display("ROL:  A=%b, B=%0d, Result=%b", input_a, input_b, ALU_result[31:0]);
    
    opROL=0; opROR=1; #5; // ROR: rotate right by 2
    $display("ROR:  A=%b, B=%0d, Result=%b", input_a, input_b, ALU_result[31:0]);

    //Test Edge Cases
    input_a = 32'd0;
    input_b = 32'd1;

    opROR=0; opDIV=1; #5;  // DIV: 0 / 1 = 0
    $display("DIV0: A=%0d, B=%0d, Result=%0d (expected 0)", input_a, input_b, ALU_result[31:0]);

    opDIV=0; opMUL=1; #5;  // MUL: 0 * 1 = 0
    $display("MUL0: A=%0d, B=%0d, Result=%0d (expected 0)", input_a, input_b, ALU_result[31:0]);

    input_a = 32'd10;
    input_b = 32'd0;

    opMUL=0; opDIV=1; #5;  // DIV by zero
    $display("DIVZ: A=%0d, B=%0d, Result=%h (implementation-defined)", input_a, input_b, ALU_result);

    input_a = -32'd20;
    input_b = 32'd5;

    opDIV=0; opADD=1; #5;  // ADD signed
    $display("ADD:  A=%0d, B=%0d, Result=%0d (expected -15)", $signed(input_a), input_b, $signed(ALU_result[31:0]));

    opADD=0; opSUB=1; #5;  // SUB signed
    $display("SUB:  A=%0d, B=%0d, Result=%0d (expected -25)", $signed(input_a), input_b, $signed(ALU_result[31:0]));

    opSUB=0; opMUL=1; #5;  // MUL signed
    $display("MUL:  A=%0d, B=%0d, Result=%0d (expected -100)", $signed(input_a), input_b, $signed(ALU_result));

    opMUL=0; opDIV=1; #5;  // DIV signed
    $display("DIV:  A=%0d, B=%0d, Result=%0d (expected -4)", $signed(input_a), input_b, $signed(ALU_result[31:0]));
    
    input_a = 32'h7FFFFFFF;
    input_b = 32'd1;

    opDIV=0; opADD=1; #5;  // ADD overflow
    $display("OVF:  A=%0d, B=%0d, Result=%0d (overflow)", input_a, input_b, $signed(ALU_result[31:0]));

    input_a = 32'hA5A5A5A5;
    input_b = 32'd32;

    opROR=0; opROL=1; #5; // ROL by 32
    $display("ROL32: Result=%h", ALU_result[31:0]);

    opROL=0; opROR=1; #5; // ROR by 32
    $display("ROR32: Result=%h", ALU_result[31:0]);

    $display("\n=== All tests complete ===");
    #5 $finish;

  end

endmodule
