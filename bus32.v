module bus32(
    //inputs from all registers to go on bus
    //only one can be active (on bus) at a time
    input wire [31:0] BusMuxIn_R0,
    input wire [31:0] BusMuxIn_R1,
    input wire [31:0] BusMuxIn_R2,
    input wire [31:0] BusMuxIn_R3,
    input wire [31:0] BusMuxIn_R4,
    input wire [31:0] BusMuxIn_R5,
    input wire [31:0] BusMuxIn_R6,
    input wire [31:0] BusMuxIn_R7,
    input wire [31:0] BusMuxIn_R8,
    input wire [31:0] BusMuxIn_R9,
    input wire [31:0] BusMuxIn_R10,
    input wire [31:0] BusMuxIn_R11,
    input wire [31:0] BusMuxIn_R12,
    input wire [31:0] BusMuxIn_R13,
    input wire [31:0] BusMuxIn_R14,
    input wire [31:0] BusMuxIn_R15,

    input wire [31:0] BusMuxIn_HI,
    input wire [31:0] BusMuxIn_LO,
    input wire [31:0] BusMuxIn_Zhigh,
    input wire [31:0] BusMuxIn_Zlow,
    input wire [31:0] BusMuxIn_PC,
    input wire [31:0] BusMuxIn_MDR,
    input wire [31:0] BusMuxIn_InPort,
    input wire [31:0] C_sign_extended,

    //control signals - tells which input (^) goes on bus
    //1 -> active, 0 -> inactive
    input wire R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, R8out, 
    R9out, R10out, R11out, R12out, R13out, R14out, R15out,
    input wire HIout, LOout, Zhighout, Zlowout,
    input wire PCout, MDRout, InPortout, Cout,

    //output (bus)
    output reg [31:0] BusMuxOut
);
    
    always @(*) begin
        case (1'b1)  //find whose control signal is 1
            R0out:    BusMuxOut = BusMuxIn_R0;
            R1out:    BusMuxOut = BusMuxIn_R1;
            R2out:    BusMuxOut = BusMuxIn_R2;
            R3out:    BusMuxOut = BusMuxIn_R3;
            R4out:    BusMuxOut = BusMuxIn_R4;
            R5out:    BusMuxOut = BusMuxIn_R5;
            R6out:    BusMuxOut = BusMuxIn_R6;
            R7out:    BusMuxOut = BusMuxIn_R7;
            R8out:    BusMuxOut = BusMuxIn_R8;
            R9out:    BusMuxOut = BusMuxIn_R9;
            R10out:    BusMuxOut = BusMuxIn_R10;
            R11out:    BusMuxOut = BusMuxIn_R11;
            R12out:    BusMuxOut = BusMuxIn_R12;
            R13out:    BusMuxOut = BusMuxIn_R13;
            R14out:    BusMuxOut = BusMuxIn_R14;
            R15out:    BusMuxOut = BusMuxIn_R15;
            HIout:    BusMuxOut = BusMuxIn_HI;
            LOout:    BusMuxOut = BusMuxIn_LO;
            Zhighout: BusMuxOut = BusMuxIn_Zhigh;
            Zlowout:  BusMuxOut = BusMuxIn_Zlow;
            PCout:    BusMuxOut = BusMuxIn_PC;
            MDRout:   BusMuxOut = BusMuxIn_MDR;
            InPortout:BusMuxOut = BusMuxIn_InPort;
            Cout:     BusMuxOut = C_sign_extended;
            default:  BusMuxOut = 32'd0;
        endcase
    end

endmodule