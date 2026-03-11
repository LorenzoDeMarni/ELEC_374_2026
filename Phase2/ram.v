module ram(
    input wire clock,
    input wire Read,
    input wire Write,
    input wire [8:0] address,
    input wire [31:0] DataIn,
    output reg [31:0] Mdataout
);

    reg [31:0] memory [0:511];

    // preload test values
    initial begin
        memory[9'h065] = 32'h00000084;  // ld case 1: MEM[0x65] = 0x84
        memory[9'h0C9] = 32'h0000002B;  // ld case 2: MEM[0xC9] = 0x2B
        memory[9'h01F] = 32'h000000D4;  // st case 1: initial MEM[0x1F] = 0xD4
        memory[9'h082] = 32'h000000A7;  // st case 2: initial MEM[0x82] = 0xA7
    end

    always @(posedge clock) begin
        if (Write)
            memory[address] <= DataIn;
        if (Read)
            Mdataout <= memory[address];
    end

endmodule