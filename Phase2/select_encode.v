module select_encode(
    input wire [31:0] IR,
    input wire Gra, Grb, Grc,
    input wire Rin, Rout, BAout,

    output wire R0in,  R1in,  R2in,  R3in,
    output wire R4in,  R5in,  R6in,  R7in,
    output wire R8in,  R9in,  R10in, R11in,
    output wire R12in, R13in, R14in, R15in,

    output wire R0out,  R1out,  R2out,  R3out,
    output wire R4out,  R5out,  R6out,  R7out,
    output wire R8out,  R9out,  R10out, R11out,
    output wire R12out, R13out, R14out, R15out
);

    // extract register fields from IR
    wire [3:0] Ra = IR[26:23];
    wire [3:0] Rb = IR[22:19];
    wire [3:0] Rc = IR[18:15];

    // select which field to decode based on Gra/Grb/Grc
    reg [3:0] sel;
    always @(*) begin
        if      (Gra) sel = Ra;
        else if (Grb) sel = Rb;
        else if (Grc) sel = Rc;
        else          sel = 4'd0;
    end

    // 4-to-16 decoder
    wire [15:0] decoded;
    assign decoded[0]  = (sel == 4'd0);
    assign decoded[1]  = (sel == 4'd1);
    assign decoded[2]  = (sel == 4'd2);
    assign decoded[3]  = (sel == 4'd3);
    assign decoded[4]  = (sel == 4'd4);
    assign decoded[5]  = (sel == 4'd5);
    assign decoded[6]  = (sel == 4'd6);
    assign decoded[7]  = (sel == 4'd7);
    assign decoded[8]  = (sel == 4'd8);
    assign decoded[9]  = (sel == 4'd9);
    assign decoded[10] = (sel == 4'd10);
    assign decoded[11] = (sel == 4'd11);
    assign decoded[12] = (sel == 4'd12);
    assign decoded[13] = (sel == 4'd13);
    assign decoded[14] = (sel == 4'd14);
    assign decoded[15] = (sel == 4'd15);

    // Rnin: decoded AND Rin
    assign R0in  = decoded[0]  & Rin;
    assign R1in  = decoded[1]  & Rin;
    assign R2in  = decoded[2]  & Rin;
    assign R3in  = decoded[3]  & Rin;
    assign R4in  = decoded[4]  & Rin;
    assign R5in  = decoded[5]  & Rin;
    assign R6in  = decoded[6]  & Rin;
    assign R7in  = decoded[7]  & Rin;
    assign R8in  = decoded[8]  & Rin;
    assign R9in  = decoded[9]  & Rin;
    assign R10in = decoded[10] & Rin;
    assign R11in = decoded[11] & Rin;
    assign R12in = decoded[12] & Rin;
    assign R13in = decoded[13] & Rin;
    assign R14in = decoded[14] & Rin;
    assign R15in = decoded[15] & Rin;

    // Rnout: decoded AND (Rout OR BAout)
    // BAout also enables the selected register onto the bus
    // the R0 special case (outputting 0) is handled in datapath.v
    assign R0out  = decoded[0]  & (Rout | BAout);
    assign R1out  = decoded[1]  & (Rout | BAout);
    assign R2out  = decoded[2]  & (Rout | BAout);
    assign R3out  = decoded[3]  & (Rout | BAout);
    assign R4out  = decoded[4]  & (Rout | BAout);
    assign R5out  = decoded[5]  & (Rout | BAout);
    assign R6out  = decoded[6]  & (Rout | BAout);
    assign R7out  = decoded[7]  & (Rout | BAout);
    assign R8out  = decoded[8]  & (Rout | BAout);
    assign R9out  = decoded[9]  & (Rout | BAout);
    assign R10out = decoded[10] & (Rout | BAout);
    assign R11out = decoded[11] & (Rout | BAout);
    assign R12out = decoded[12] & (Rout | BAout);
    assign R13out = decoded[13] & (Rout | BAout);
    assign R14out = decoded[14] & (Rout | BAout);
    assign R15out = decoded[15] & (Rout | BAout);

endmodule