module datapath(
    input wire clock, clear,

    //16 general purpose 32 bit registers
    //special registers: HI/LO for upper/lower 32 bits of Z
    //Z for mul/div results, 64 bit. holds ALU results
    //PC to track instruction address
    //IR to hold current instruction
    //MAR (memory access register) to hold mem address for read/writes
    //Y for first ALU operand, temprary storage

    //data flows through registers via bus
    //control signals select which register drives the bus (one 'out' signal)
    //ontrol signals select which registers load from bus (any 'in' signals)
    //on the clock edge, enabled registers capture the bus value

    //for ALU
    //T3: first operand goes from bus to Y register
    //T4: second operand on bus goes to ALU input B, Y goes to ALU input A
    //ALU computes, result goes to Z
    //T5: result from Z goes back onto bus to destination register
	
	//register control signals (in)
    input wire R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in,
    input wire R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in,
    input wire HIin, LOin, PCin, IRin, Yin, Zin, MARin, MDRin,
    //Phase 2 new input signals
    input wire Write,
    input wire Gra, Grb, Grc,
    input wire [31:0] InPort_data,
    input wire Rin, Rout, BAout,
    input wire Strobe,
    // output port load control
    input wire OutPortin,

    //register control signals (out)
    input wire R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out,
    input wire R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out,
    input wire HIout, LOout, Zhighout, Zlowout, PCout, MDRout, InPortout, Cout,

    //ALU control signals
    input wire IncPC, ADD, SUB, AND, OR, SHR, SHRA, SHL, ROR, ROL, NEG, NOT, MUL, DIV,

    //memory interface
    input wire Read,
    input wire [31:0] Mdatain,

    // simple input port data (from external input device)

    // branch condition latch control - Phase 2
    input wire CONin,

    //outputs for monitoring
    output wire [31:0] R0, R1, R2, R3, R4, R5, R6, R7,
    output wire [31:0] R8, R9, R10, R11, R12, R13, R14, R15,
    output wire [31:0] HI, LO, PC_out, IR, MAR,
    output wire [31:0] Y,
    output wire [63:0] Z,
    output wire [31:0] BusMuxOut_signal,

    //Phase 2 new
    // output port for OUT instruction
    output wire [31:0] OutPort,
    // branch condition flag
    output wire CONout
);

//internal wires
wire [31:0] BusMuxOut;
wire [31:0] MDR_out;
wire [31:0] InPort_reg;
wire [31:0] C_sign_extended;
wire [31:0] Y_reg;
wire [63:0] Z_reg;
wire [31:0] PC_incremented;
wire [63:0] ALU_result;
wire [31:0] OutPort_reg;
wire [31:0] RAM_dataout;

//register file instantiation (R0-R15)
wire [31:0] R0_wire, R1_wire, R2_wire, R3_wire;
wire [31:0] R4_wire, R5_wire, R6_wire, R7_wire;
wire [31:0] R8_wire, R9_wire, R10_wire, R11_wire;
wire [31:0] R12_wire, R13_wire, R14_wire, R15_wire;
wire [31:0] HI_wire, LO_wire, PC_wire, IR_wire, MAR_wire;

wire SE_R0in, SE_R1in, SE_R2in, SE_R3in, SE_R4in, SE_R5in, SE_R6in, SE_R7in;
wire SE_R8in, SE_R9in, SE_R10in, SE_R11in, SE_R12in, SE_R13in, SE_R14in, SE_R15in;
wire SE_R0out, SE_R1out, SE_R2out, SE_R3out, SE_R4out, SE_R5out, SE_R6out, SE_R7out;
wire SE_R8out, SE_R9out, SE_R10out, SE_R11out, SE_R12out, SE_R13out, SE_R14out, SE_R15out;

register32 reg_R0  (.clock(clock), .clear(clear), .enable(R0in | SE_R0in),  .BusMuxOut(BusMuxOut), .q(R0_wire));
register32 reg_R1  (.clock(clock), .clear(clear), .enable(R1in | SE_R1in),  .BusMuxOut(BusMuxOut), .q(R1_wire));
register32 reg_R2  (.clock(clock), .clear(clear), .enable(R2in | SE_R2in),  .BusMuxOut(BusMuxOut), .q(R2_wire));
register32 reg_R3  (.clock(clock), .clear(clear), .enable(R3in | SE_R3in),  .BusMuxOut(BusMuxOut), .q(R3_wire));
register32 reg_R4  (.clock(clock), .clear(clear), .enable(R4in | SE_R4in),  .BusMuxOut(BusMuxOut), .q(R4_wire));
register32 reg_R5  (.clock(clock), .clear(clear), .enable(R5in | SE_R5in),  .BusMuxOut(BusMuxOut), .q(R5_wire));
register32 reg_R6  (.clock(clock), .clear(clear), .enable(R6in | SE_R6in),  .BusMuxOut(BusMuxOut), .q(R6_wire));
register32 reg_R7  (.clock(clock), .clear(clear), .enable(R7in | SE_R7in),  .BusMuxOut(BusMuxOut), .q(R7_wire));
register32 reg_R8  (.clock(clock), .clear(clear), .enable(R8in | SE_R8in),  .BusMuxOut(BusMuxOut), .q(R8_wire));
register32 reg_R9  (.clock(clock), .clear(clear), .enable(R9in | SE_R9in),  .BusMuxOut(BusMuxOut), .q(R9_wire));
register32 reg_R10 (.clock(clock), .clear(clear), .enable(R10in | SE_R10in), .BusMuxOut(BusMuxOut), .q(R10_wire));
register32 reg_R11 (.clock(clock), .clear(clear), .enable(R11in | SE_R11in), .BusMuxOut(BusMuxOut), .q(R11_wire));
register32 reg_R12 (.clock(clock), .clear(clear), .enable(R12in | SE_R12in), .BusMuxOut(BusMuxOut), .q(R12_wire));
register32 reg_R13 (.clock(clock), .clear(clear), .enable(R13in | SE_R13in), .BusMuxOut(BusMuxOut), .q(R13_wire));
register32 reg_R14 (.clock(clock), .clear(clear), .enable(R14in | SE_R14in), .BusMuxOut(BusMuxOut), .q(R14_wire));
register32 reg_R15 (.clock(clock), .clear(clear), .enable(R15in | SE_R15in), .BusMuxOut(BusMuxOut), .q(R15_wire));
    
//special registers
// In Phase 2, HI/LO load from the main bus so that
// Z results (or any other bus source) can be latched via control.
register32 reg_HI  (.clock(clock), .clear(clear), .enable(HIin),  .BusMuxOut(BusMuxOut), .q(HI_wire));
register32 reg_LO  (.clock(clock), .clear(clear), .enable(LOin),  .BusMuxOut(BusMuxOut), .q(LO_wire));
register32 reg_PC  (.clock(clock), .clear(clear), .enable(PCin),  .BusMuxOut(BusMuxOut), .q(PC_wire));
register32 reg_IR  (.clock(clock), .clear(clear), .enable(IRin),  .BusMuxOut(BusMuxOut), .q(IR_wire));
register32 reg_MAR (.clock(clock), .clear(clear), .enable(MARin), .BusMuxOut(BusMuxOut), .q(MAR_wire));
register32 reg_Y   (.clock(clock), .clear(clear), .enable(Yin),   .BusMuxOut(BusMuxOut), .q(Y_reg));
    
//64-bit Z register
register64 reg_Z (.clock(clock), .clear(clear), .enable(Zin), .data_in(ALU_result), .q(Z_reg));

MDR mdr_unit(
    .clock(clock),
    .clear(clear),
    .MDRin(MDRin),
    .Read(Read),
    .BusMuxOut(BusMuxOut),
    .Mdatain(RAM_dataout),
    .q(MDR_out)
);

ram ram_unit(
    .clock(clock),
    .Read(Read),
    .Write(Write),
    .address(MAR_wire[8:0]),
    .DataIn(MDR_out),
    .Mdataout(RAM_dataout)
);
    
pc_incrementer pc_inc(
    .pc_in(PC_wire),
    .pc_out(PC_incremented)
);

select_encode se_unit(
    .IR(IR_wire),
    .Gra(Gra), .Grb(Grb), .Grc(Grc),
    .Rin(Rin), .Rout(Rout), .BAout(BAout),
    .R0in(SE_R0in),   .R1in(SE_R1in),   .R2in(SE_R2in),   .R3in(SE_R3in),
    .R4in(SE_R4in),   .R5in(SE_R5in),   .R6in(SE_R6in),   .R7in(SE_R7in),
    .R8in(SE_R8in),   .R9in(SE_R9in),   .R10in(SE_R10in), .R11in(SE_R11in),
    .R12in(SE_R12in), .R13in(SE_R13in), .R14in(SE_R14in), .R15in(SE_R15in),
    .R0out(SE_R0out),   .R1out(SE_R1out),   .R2out(SE_R2out),   .R3out(SE_R3out),
    .R4out(SE_R4out),   .R5out(SE_R5out),   .R6out(SE_R6out),   .R7out(SE_R7out),
    .R8out(SE_R8out),   .R9out(SE_R9out),   .R10out(SE_R10out), .R11out(SE_R11out),
    .R12out(SE_R12out), .R13out(SE_R13out), .R14out(SE_R14out), .R15out(SE_R15out)
);
    
//bus instantiation
bus32 main_bus(
    .BusMuxIn_R0(BAout ? 32'd0 : R0_wire),   .BusMuxIn_R1(R1_wire),   .BusMuxIn_R2(R2_wire),   .BusMuxIn_R3(R3_wire),
    .BusMuxIn_R4(R4_wire),   .BusMuxIn_R5(R5_wire),   .BusMuxIn_R6(R6_wire),   .BusMuxIn_R7(R7_wire),
    .BusMuxIn_R8(R8_wire),   .BusMuxIn_R9(R9_wire),   .BusMuxIn_R10(R10_wire), .BusMuxIn_R11(R11_wire),
    .BusMuxIn_R12(R12_wire), .BusMuxIn_R13(R13_wire), .BusMuxIn_R14(R14_wire), .BusMuxIn_R15(R15_wire),
    .BusMuxIn_HI(HI_wire),   .BusMuxIn_LO(LO_wire),
    .BusMuxIn_Zhigh(Z_reg[63:32]), .BusMuxIn_Zlow(Z_reg[31:0]),
    .BusMuxIn_PC(IncPC ? PC_incremented : PC_wire),
    .BusMuxIn_MDR(MDR_out),
    .BusMuxIn_InPort(InPort_reg),
    .C_sign_extended(C_sign_extended),
    .R0out(R0out | SE_R0out),   .R1out(R1out | SE_R1out),   .R2out(R2out | SE_R2out),   .R3out(R3out | SE_R3out),
    .R4out(R4out | SE_R4out),   .R5out(R5out | SE_R5out),   .R6out(R6out | SE_R6out),   .R7out(R7out | SE_R7out),
    .R8out(R8out | SE_R8out),   .R9out(R9out | SE_R9out),   .R10out(R10out | SE_R10out), .R11out(R11out | SE_R11out),
    .R12out(R12out | SE_R12out), .R13out(R13out | SE_R13out), .R14out(R14out | SE_R14out), .R15out(R15out | SE_R15out),
    .HIout(HIout),   .LOout(LOout),
    .Zhighout(Zhighout), .Zlowout(Zlowout),
    .PCout(PCout),   .MDRout(MDRout), .InPortout(InPortout), .Cout(Cout),
    .BusMuxOut(BusMuxOut)
);

//ALU instantiation
ALU alu_instance(
    .A(Y_reg),
    .B(BusMuxOut),
    .opAND(AND),
    .opOR(OR),
    .opNOT(NOT),
    .opNEG(NEG),
    .opADD(ADD),
    .opSUB(SUB),
    .opMUL(MUL),
    .opDIV(DIV),
    .opSHR(SHR),
    .opSHRA(SHRA),
    .opSHL(SHL),
    .opROR(ROR),
    .opROL(ROL),
    .result(ALU_result)
);

// CON FF instantiation
con_ff branch_condition(
    .clk(clock),
    .clr(clear),
    .CONin(CONin),
    .Bus(BusMuxOut),
    .IR_20_19(IR_wire[20:19]),
    .CON(CONout)
);

register32 reg_InPort(
    .clock(clock),
    .clear(clear),
    .enable(Strobe),
    .BusMuxOut(InPort_data),
    .q(InPort_reg)
);

//C sign extension for constant C field in IR (IR[18:0])
//Sign-extend from bit 18 (MSB of C) to 32 bits
assign C_sign_extended = {{13{IR_wire[18]}}, IR_wire[18:0]};

// Output port register: captures bus value when used by OUT instruction
register32 reg_OutPort(
    .clock(clock),
    .clear(clear),
    .enable(OutPortin),
    .BusMuxOut(BusMuxOut),
    .q(OutPort_reg)
);

//output assignments for monitoring
assign R0 = R0_wire;   assign R1 = R1_wire;   assign R2 = R2_wire;   assign R3 = R3_wire;
assign R4 = R4_wire;   assign R5 = R5_wire;   assign R6 = R6_wire;   assign R7 = R7_wire;
assign R8 = R8_wire;   assign R9 = R9_wire;   assign R10 = R10_wire; assign R11 = R11_wire;
assign R12 = R12_wire; assign R13 = R13_wire; assign R14 = R14_wire; assign R15 = R15_wire;
assign HI = HI_wire;
assign LO = LO_wire;
assign PC_out = PC_wire;
assign IR = IR_wire;
assign MAR = MAR_wire;
assign Y = Y_reg;
assign Z = Z_reg;
assign BusMuxOut_signal = BusMuxOut;
assign OutPort = OutPort_reg;

endmodule

//to test, run:
//iverilog -o test.out datapath_tb.v datapath.v register32.v register64.v bus32.v MDR.v pc_incrementer.v
//vvp test.out
//gtkwave datapath.vcd