`timescale 1ns/10ps

// Jump testbench: exercises jr and jal behavior

module jump_tb;

    reg clock;
    reg clear;
    
    //register control signals
    reg R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in;
    reg R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in;
    reg HIin, LOin, PCin, IRin, Yin, Zin, MARin, MDRin, OutPortin;
    
    reg R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out;
    reg R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out;
    reg HIout, LOout, Zhighout, Zlowout, PCout, MDRout, InPortout, Cout;
    
    //ALU control signals
    reg IncPC, ADD, SUB, AND, OR, SHR, SHRA, SHL, ROR, ROL, NEG, NOT, MUL, DIV;
    
    reg Read;
    reg [31:0] Mdatain;
    reg [31:0] InPort_data;

    reg CONin;

    wire [31:0] R0, R1, R2, R3, R4, R5, R6, R7;
    wire [31:0] R8, R9, R10, R11, R12, R13, R14, R15;
    wire [31:0] HI, LO, PC_out, IR, MAR, Y;
    wire [63:0] Z;
    wire [31:0] BusMuxOut_signal;
    wire [31:0] OutPort;
    wire CON;

    // states
    parameter Default     = 4'b0000,
              Load_R12    = 4'b0001,
              Load_PC     = 4'b0010,
              JR_T3       = 4'b0011,
              JAL_SaveRA  = 4'b0100,
              JAL_LoadPC  = 4'b0101;

    reg [3:0] Present_state = Default;

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

    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    always @(posedge clock) begin
        case (Present_state)
            Default:    Present_state = Load_R12;
            Load_R12:   Present_state = Load_PC;
            Load_PC:    Present_state = JR_T3;
            JR_T3:      Present_state = JAL_SaveRA;
            JAL_SaveRA: Present_state = JAL_LoadPC;
            JAL_LoadPC: Present_state = JAL_LoadPC;
            default:    Present_state = Default;
        endcase
    end

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
        Read = 0; Mdatain = 32'h00000000; clear = 0; InPort_data = 32'h00000000;
        CONin = 0;

        case (Present_state)
            Default: begin
                clear = 1;
            end

            // preload R12 with jump target (0x000000FF)
            Load_R12: begin
                Mdatain = 32'h000000FF;
                Read = 1;
                MDRin = 1;
            end

            Load_PC: begin
                MDRout = 1;
                R12in  = 1;         // R12 = 0xFF (RA for jr)
                // also set PC to 0x00000010
                // reuse MDR path
            end

            // jr R12: PC <- R12
            JR_T3: begin
                R12out = 1;
                PCin   = 1;
            end

            // jal R4: save PC+1 into R12 (RA)
            JAL_SaveRA: begin
                PCout = 1;
                IncPC = 1;
                R12in = 1;  // RA <= PC+1
            end

            // jal R4: PC <- R4
            JAL_LoadPC: begin
                R4out = 1;
                PCin  = 1;
            end
        endcase
    end

    initial begin
        $dumpfile("jump.vcd");
        $dumpvars(0, jump_tb);
        #300;
        $display("Jump test complete");
        $display("R12 (RA) = 0x%h", R12);
        $display("PC_out = 0x%h", PC_out);
        $finish;
    end

endmodule

