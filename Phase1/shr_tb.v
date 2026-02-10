//tests SHR R7, R0, R4
`timescale 1ns/10ps 

module shr_tb;

    reg clock;
    reg clear;
    
    //register control signals
    reg R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in;
    reg R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in;
    reg HIin, LOin, PCin, IRin, Yin, Zin, MARin, MDRin;
    
    reg R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out;
    reg R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out;
    reg HIout, LOout, Zhighout, Zlowout, PCout, MDRout, InPortout, Cout;
    
    //ALU control signals
    reg IncPC, ADD, SUB, AND, OR, SHR, SHRA, SHL, ROR, ROL, NEG, NOT, MUL, DIV;
    
    reg Read;
    reg [31:0] Mdatain;
    
    //outputs
    wire [31:0] R0, R1, R2, R3, R4, R5, R6, R7;
    wire [31:0] R8, R9, R10, R11, R12, R13, R14, R15;
    wire [31:0] HI, LO, PC_out, IR, MAR, Y;
    wire [63:0] Z;
    wire [31:0] BusMuxOut_signal;
    
    //state machine
    parameter Default    = 4'b0000,
              Reg_load1a = 4'b0001,
              Reg_load1b = 4'b0010,
              Reg_load2a = 4'b0011,
              Reg_load2b = 4'b0100,
              T0         = 4'b0101,
              T1         = 4'b0110,
              T2         = 4'b0111,
              T3         = 4'b1000,
              T4         = 4'b1001,
              T5         = 4'b1010;
    
    reg [3:0] Present_state = Default;
    
    //instantiate DUT
    datapath DUT(
        .clock(clock), .clear(clear),
        .R0in(R0in), .R1in(R1in), .R2in(R2in), .R3in(R3in),
        .R4in(R4in), .R5in(R5in), .R6in(R6in), .R7in(R7in),
        .R8in(R8in), .R9in(R9in), .R10in(R10in), .R11in(R11in),
        .R12in(R12in), .R13in(R13in), .R14in(R14in), .R15in(R15in),
        .HIin(HIin), .LOin(LOin), .PCin(PCin), .IRin(IRin),
        .Yin(Yin), .Zin(Zin), .MARin(MARin), .MDRin(MDRin),
        .R0out(R0out), .R1out(R1out), .R2out(R2out), .R3out(R3out),
        .R4out(R4out), .R5out(R5out), .R6out(R6out), .R7out(R7out),
        .R8out(R8out), .R9out(R9out), .R10out(R10out), .R11out(R11out),
        .R12out(R12out), .R13out(R13out), .R14out(R14out), .R15out(R15out),
        .HIout(HIout), .LOout(LOout), .Zhighout(Zhighout), .Zlowout(Zlowout),
        .PCout(PCout), .MDRout(MDRout), .InPortout(InPortout), .Cout(Cout),
        .IncPC(IncPC), .ADD(ADD), .SUB(SUB), .AND(AND), .OR(OR),
        .SHR(SHR), .SHRA(SHRA), .SHL(SHL), .ROR(ROR), .ROL(ROL),
        .NEG(NEG), .NOT(NOT), .MUL(MUL), .DIV(DIV),
        .Read(Read), .Mdatain(Mdatain),
        .R0(R0), .R1(R1), .R2(R2), .R3(R3), .R4(R4), .R5(R5), .R6(R6), .R7(R7),
        .R8(R8), .R9(R9), .R10(R10), .R11(R11), .R12(R12), .R13(R13), .R14(R14), .R15(R15),
        .HI(HI), .LO(LO), .PC_out(PC_out), .IR(IR), .MAR(MAR),
        .Y(Y), .Z(Z), .BusMuxOut_signal(BusMuxOut_signal)
    );
    
    //clock generation
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end
    
    //state machine
    always @(posedge clock) begin
        case (Present_state)
            Default:    Present_state = Reg_load1a;
            Reg_load1a: Present_state = Reg_load1b;
            Reg_load1b: Present_state = Reg_load2a;
            Reg_load2a: Present_state = Reg_load2b;
            Reg_load2b: Present_state = T0;
            T0:         Present_state = T1;
            T1:         Present_state = T2;
            T2:         Present_state = T3;
            T3:         Present_state = T4;
            T4:         Present_state = T5;
        endcase
    end
    
    //control logic
    always @(Present_state) begin
        //all signals off by default
        R0in = 0; R1in = 0; R2in = 0; R3in = 0; R4in = 0; R5in = 0; R6in = 0; R7in = 0;
        R8in = 0; R9in = 0; R10in = 0; R11in = 0; R12in = 0; R13in = 0; R14in = 0; R15in = 0;
        HIin = 0; LOin = 0; PCin = 0; IRin = 0; Yin = 0; Zin = 0; MARin = 0; MDRin = 0;
        R0out = 0; R1out = 0; R2out = 0; R3out = 0; R4out = 0; R5out = 0; R6out = 0; R7out = 0;
        R8out = 0; R9out = 0; R10out = 0; R11out = 0; R12out = 0; R13out = 0; R14out = 0; R15out = 0;
        HIout = 0; LOout = 0; Zhighout = 0; Zlowout = 0; PCout = 0; MDRout = 0; InPortout = 0; Cout = 0;
        IncPC = 0; ADD = 0; SUB = 0; AND = 0; OR = 0; SHR = 0; SHRA = 0; SHL = 0;
        ROR = 0; ROL = 0; NEG = 0; NOT = 0; MUL = 0; DIV = 0;
        Read = 0; Mdatain = 32'h00000000; clear = 0;
        
        case (Present_state)
            Default: begin
                clear = 1;
            end
            
            //load R0 with 0xF0000000 (value to shift)
            Reg_load1a: begin
                Mdatain = 32'hF0000000;
                Read = 1;
                MDRin = 1;
            end
            Reg_load1b: begin
                MDRout = 1;
                R0in = 1;
            end
            
            //load R4 with 0x00000004 (shift amount = 4)
            Reg_load2a: begin
                Mdatain = 32'h00000004;
                Read = 1;
                MDRin = 1;
            end
            Reg_load2b: begin
                MDRout = 1;
                R4in = 1;
            end
            
            // T0: instruction fetch
            T0: begin
                PCout = 1;
                MARin = 1;
                IncPC = 1;
                Zin = 1;
            end
            
            // T1: PC <- Z, IR <- Mdatain
            T1: begin
                Zlowout = 1;
                PCin = 1;
                Read = 1;
                MDRin = 1;
                Mdatain = 32'h04704000;  // SHR R7, R0, R4 (opcode 00100, Ra=7, Rb=0, Rc=4 per Mini SRC spec)
            end
            
            // T2: IR <- MDR
            T2: begin
                MDRout = 1;
                IRin = 1;
            end
            
            // T3: Y <- R0
            T3: begin
                R0out = 1;
                Yin = 1;
            end
            
            // T4: Z <- R0 >> R4 (shift right)
            T4: begin
                R4out = 1;  // R4 has shift amount
                SHR = 1;
                Zin = 1;
            end
            
            // T5: R7 <- Z
            T5: begin
                Zlowout = 1;
                R7in = 1;
            end
        endcase
    end
    
    initial begin
        $dumpfile("shr.vcd");
        $dumpvars(0, shr_tb);
        #300;
        $display("Simulation complete");
        $display("R0 = 0x%h (value to shift)", R0);
        $display("R4 = 0x%h (shift amount)", R4);
        $display("R7 = 0x%h (expected: 0xF0000000 >> 4 = 0x0F000000)", R7);
        $finish;
    end

endmodule