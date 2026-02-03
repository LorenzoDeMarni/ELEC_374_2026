module register32(
    input wire clock,
    input wire clear, //reset, clear to 0
    input wire enable,
    input wire [31:0] BusMuxOut, //32-bit data from bus
    output reg [31:0] q //32-bit stored val
);

    always @(posedge clock) begin //updates stored 32-bit num on pos clock edge
        if (clear)
            q <= 32'd0;          //clears to 0 if clear=1, 32'd0 means 32-bit decimal val of 0
        else if (enable)
            q <= BusMuxOut;      //save if enable=1
    end

endmodule