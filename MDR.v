module MDR(
    input wire clock,
    input wire clear,
    input wire MDRin, //enable signal
    input wire Read, //choose input
    input wire [31:0] BusMuxOut, //input from bus
    input wire [31:0] Mdatain, //input from mem
    output reg [31:0] q //stored value
);

    wire [31:0] mdr_mux_out;
    
    //select between bus and memory input
    //if Read = 1 -> Mdatain, if Read = 0 -> BusMuxOut
    assign mdr_mux_out = Read ? Mdatain : BusMuxOut;
    
    always @(posedge clock) begin
        if (clear)
            q <= 32'd0;
        else if (MDRin)
            q <= mdr_mux_out; //save selected input
    end

endmodule
