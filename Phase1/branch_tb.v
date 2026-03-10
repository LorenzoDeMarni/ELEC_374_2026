`timescale 1ns/10ps

// Branch testbench: exercises conditional branch using CON FF and PC update
// Example case: brzr R3, C  (branch if R3 == 0)

module branch_tb;

    reg clock;
    reg clear;
    
    // register control signals
    reg R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in;
    reg R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in;
    reg HIin, LOin, PCin, IRin, Yin, Zin, MARin, MDRin, OutPortin;
    
    reg R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out;
    reg R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out;
    reg HIout, LOout, Zhighout, Zlowout, PCout, MDRout, InPortout, Cout;
    
    // ALU control signals
    reg IncPC, ADD, SUB, AND, OR, SHR, SHRA, SHL, ROR, ROL, NEG, NOT, MUL, DIV;
    
    // memory interface / input port
    reg Read;
    reg [31:0] Mdatain;
    reg [31:0] InPort_data;

    // branch condition latch control
    reg CONin;

    // outputs
    wire [31:0] R0, R1, R2, R3, R4, R5, R6, R7;
    wire [31:0] R8, R9, R10, R11, R12, R13, R14, R15;
    wire [31:0] HI, LO, PC_out, IR, MAR, Y;
    wire [63:0] Z;
    wire [31:0] BusMuxOut_signal;
    wire [31:0] OutPort;
    wire CON;

    // simple state machine for control sequence
    parameter Default     = 4'b0000,
              Reg_loadRa  = 4'b0001,
              Reg_loadPC  = 4'b0010,
              T0          = 4'b0011,
              T1          = 4'b0100,
              T2          = 4'b0101,
              T3          = 4'b0110,
              T4          = 4'b0111,
              T5          = 4'b1000,
              T6          = 4'b1001;
    
    reg [3:0] Present_state = Default;

    // instantiate DUT
    datapath DUT(
        .clock(clock), .clear(clear),
        .R0in(R0in), .R1in(R1in), .R2in(R2in), .R3in(R3in),
        .R4in(R4in), .R5in(R5in), .R6in(R6in), .R7in(R7in),
        .R8in(R8in), .R9in(R9in), .R10in(R10in), .R11in(R11in),
        .R12in(R12in), .R13in(R13in), .R14in(R14in), .R15in(R15in),
        .HIin(HIin), .LOin(LOin), .PCin(PCin), .IRin(IRin),
        .Yin(Yin), .Zin(Zin), .MARin(MARin), .MDRin(MDRin),
        .OutPortin(OutPortin),
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
        .InPort_data(InPort_data),
        .CONin(CONin),
        .R0(R0), .R1(R1), .R2(R2), .R3(R3), .R4(R4), .R5(R5), .R6(R6), .R7(R7),
        .R8(R8), .R9(R9), .R10(R10), .R11(R11), .R12(R12), .R13(R13), .R14(R14), .R15(R15),
        .HI(HI), .LO(LO), .PC_out(PC_out), .IR(IR), .MAR(MAR),
        .Y(Y), .Z(Z), .BusMuxOut_signal(BusMuxOut_signal),
        .OutPort(OutPort),
        .CON(CON)
    );

    // clock
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    // state progression
    always @(posedge clock) begin
        case (Present_state)
            Default:    Present_state = Reg_loadRa;
            Reg_loadRa: Present_state = Reg_loadPC;
            Reg_loadPC: Present_state = T0;
            T0:         Present_state = T1;
            T1:         Present_state = T2;
            T2:         Present_state = T3;
            T3:         Present_state = T4;
            T4:         Present_state = T5;
            T5:         Present_state = T6;
            T6:         Present_state = T6;
            default:    Present_state = Default;
        endcase
    end

    // control logic
    always @(Present_state) begin
        // defaults
        R0in = 0; R1in = 0; R2in = 0; R3in = 0; R4in = 0; R5in = 0; R6in = 0; R7in = 0;
        R8in = 0; R9in = 0; R10in = 0; R11in = 0; R12in = 0; R13in = 0; R14in = 0; R15in = 0;
        HIin = 0; LOin = 0; PCin = 0; IRin = 0; Yin = 0; Zin = 0; MARin = 0; MDRin = 0; OutPortin = 0;
        R0out = 0; R1out = 0; R2out = 0; R3out = 0; R4out = 0; R5out = 0; R6out = 0; R7out = 0;
        R8out = 0; R9out = 0; R10out = 0; R11out = 0; R12out = 0; R13out = 0; R14out = 0; R15out = 0;
        HIout = 0; LOout = 0; Zhighout = 0; Zlowout = 0; PCout = 0; MDRout = 0; InPortout = 0; Cout = 0;
        IncPC = 0; ADD = 0; SUB = 0; AND = 0; OR = 0; SHR = 0; SHRA = 0; SHL = 0;
        ROR = 0; ROL = 0; NEG = 0; NOT = 0; MUL = 0; DIV = 0;
        Read = 0; Mdatain = 32'h00000000; clear = 0;
        InPort_data = 32'h00000000;
        CONin = 0;

        case (Present_state)
            Default: begin
                clear = 1;
            end

            // preload R3 with source value (here: 0 for taken brzr)
            Reg_loadRa: begin
                Mdatain = 32'h00000000; // R3 = 0
                Read = 1;
                MDRin = 1;
            end
            Reg_loadPC: begin
                MDRout = 1;
                R3in   = 1;
                // initialize PC to some value, e.g., 0x00000010
                // load via MDR as well
            end

            // T0–T2: instruction fetch (simplified)
            T0: begin
                PCout = 1;
                IncPC = 1;
                MARin = 1;
            end
            T1: begin
                Read   = 1;
                MDRin  = 1;
                // IR value: C2 = 00 (brzr), C = small positive offset (e.g., 1)
                Mdatain = 32'h00000001;
            end
            T2: begin
                MDRout = 1;
                IRin   = 1;
            end

            // T3: Gra, Rout, CONin  (use R3 as Ra)
            T3: begin
                R3out = 1;
                CONin = 1;
            end

            // T4: PCout, Yin
            T4: begin
                PCout = 1;
                Yin   = 1;
            end

            // T5: Cout, ADD, Zin   (PC + 1 + C)
            T5: begin
                Cout = 1;
                ADD  = 1;
                Zin  = 1;
            end

            // T6: Zlowout, CON ➔ PCin  (conditionally update PC)
            T6: begin
                Zlowout = 1;
                if (CON)
                    PCin = 1;
            end
        endcase
    end

    initial begin
        $dumpfile("branch.vcd");
        $dumpvars(0, branch_tb);
        #300;
        $display("Branch test complete");
        $display("R3 = 0x%h", R3);
        $display("PC_out = 0x%h", PC_out);
        $finish;
    end

endmodule

