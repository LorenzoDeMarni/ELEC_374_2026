`timescale 1ns/10ps
module ALU_tb;

  reg [31:0] input_a, input_b;
  reg AND, OR, NOT, NEG;
  reg ADD, SUB, MUL, DIV;
  reg SHR, SHRA, SHL, ROR, ROL;

  wire [63:0] ALU_result;

    ALU ALU_instance(
    .A(input_a),
    .B(input_b),
    .AND(AND),
    .OR(OR),
    .NOT(NOT),
    .NEG(NEG),
    .ADD(ADD),
    .SUB(SUB),
    .MUL(MUL),
    .DIV(DIV),
    .SHR(SHR),
    .SHRA(SHRA),
    .SHL(SHL),
    .ROR(ROR),
    .ROL(ROL),
    .result(ALU_result)
  );

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars;

    AND=0; OR=0; NOT=0; NEG=0;
    ADD=0; SUB=0; MUL=0; DIV=0;
    SHR=0; SHRA=0; SHL=0; ROR=0; ROL=0;
    
    // Test values
    input_a = 32'd20;
    input_b = 32'd5;
    
    // Test each operation

    //Basic Operations
    OR=1; #20;  // OR: 20 | 5 = 21
    $display("OR:   A=%0d, B=%0d, Result=%0d (expected 21)", input_a, input_b, ALU_result[31:0]);
    
    OR=0; AND=1; #20;  // AND: 20 & 5 = 4
    $display("AND:  A=%0d, B=%0d, Result=%0d (expected 4)", input_a, input_b, ALU_result[31:0]);
    
    AND=0; NOT=1; #20;  // NOT: ~20 = 235
    $display("NOT:  A=%0d, Result=%0d (expected -21)", input_a, $signed(ALU_result[31:0]));

    NOT=0; ADD=1; #20;  // ADD: 20 + 5 = 25
    $display("ADD:  A=%0d, B=%0d, Result=%0d (expected 25)", input_a, input_b, ALU_result[31:0]);
    
    ADD=0; SUB=1; #20;  // SUB: 20 - 5 = 15
    $display("SUB:  A=%0d, B=%0d, Result=%0d (expected 15)", input_a, input_b, ALU_result[31:0]);
    
    SUB=0; NEG=1; #20;  // NEG: -20 = 236 (in 8-bit unsigned)
    $display("NEG:  A=%0d, Result=%0d (expected -20)", input_a, $signed(ALU_result[31:0]));   

    NEG=0; MUL=1; #20;  // MUL: 20 * 5 = 100
    $display("MUL:  A=%0d, B=%0d, Result=%0d (expected 100)", input_a, input_b, ALU_result[31:0]);

    MUL=0; DIV=1; #20;  // DIV: 20 / 5 = 4
    $display("DIV:  A=%0d, B=%0d, Result=%0d (expected 4)", input_a, input_b, ALU_result[31:0]);
   
    // Test shifts and rotates
    input_a = 32'b10110010;  // 178
    input_b = 32'd2;         // Shift amount
    
    DIV=0; SHL=1; #20;  // SHL: 10110010 << 2 = 11001000 (200)
    $display("SHL:  A=%b, B=%0d, Result=%b (expected 11001000)", input_a, input_b, ALU_result[31:0]);
    
    SHL=0; SHR=1; #20;  // SHR: 10110010 >> 2 = 00101100 (44)
    $display("SHR:  A=%b, B=%0d, Result=%b (expected 00101100)", input_a, input_b, ALU_result[31:0]);
    
    SHR=0; ROL=1; #20; // ROL: rotate left by 2
    $display("ROL:  A=%b, B=%0d, Result=%b", input_a, input_b, ALU_result[31:0]);
    
    ROL=0; ROR=1; #20; // ROR: rotate right by 2
    $display("ROR:  A=%b, B=%0d, Result=%b", input_a, input_b, ALU_result[31:0]);

    //Test Edge Cases
    input_a = 32'd0;
    input_b = 32'd1;

    ROR=0; DIV=1; #20;  // DIV: 0 / 1 = 0
    $display("DIV0: A=%0d, B=%0d, Result=%0d (expected 0)", input_a, input_b, ALU_result[31:0]);

    DIV=0; MUL=1; #20;  // MUL: 0 * 1 = 0
    $display("MUL0: A=%0d, B=%0d, Result=%0d (expected 0)", input_a, input_b, ALU_result[31:0]);

    input_a = 32'd10;
    input_b = 32'd0;

    MUL=0; DIV=1; #20;  // DIV by zero
    $display("DIVZ: A=%0d, B=%0d, Result=%h (implementation-defined)", input_a, input_b, ALU_result);

    input_a = -32'd20;
    input_b = 32'd5;

    DIV=0; ADD=1; #20;  // ADD signed
    $display("ADD:  A=%0d, B=%0d, Result=%0d (expected -15)", $signed(input_a), input_b, $signed(ALU_result[31:0]));

    ADD=0; SUB=1; #20;  // SUB signed
    $display("SUB:  A=%0d, B=%0d, Result=%0d (expected -25)", $signed(input_a), input_b, $signed(ALU_result[31:0]));

    SUB=0; MUL=1; #20;  // MUL signed
    $display("MUL:  A=%0d, B=%0d, Result=%0d (expected -100)", $signed(input_a), input_b, $signed(ALU_result));

    MUL=0; DIV=1; #20;  // DIV signed
    $display("DIV:  A=%0d, B=%0d, Result=%0d (expected -4)", $signed(input_a), input_b, $signed(ALU_result[31:0]));
    
    input_a = 32'h7FFFFFFF;
    input_b = 32'd1;

    DIV=0; ADD=1; #20;  // ADD overflow
    $display("OVF:  A=%0d, B=%0d, Result=%0d (overflow)", input_a, input_b, $signed(ALU_result[31:0]));

    input_a = 32'hA5A5A5A5;
    input_b = 32'd32;

    ROR=0; ROL=1; #20; // ROL by 32
    $display("ROL32: Result=%h", ALU_result[31:0]);

    ROL=0; ROR=1; #20; // ROR by 32
    $display("ROR32: Result=%h", ALU_result[31:0]);

    $display("\n=== All tests complete ===");
    #20 $finish;

  end

endmodule
