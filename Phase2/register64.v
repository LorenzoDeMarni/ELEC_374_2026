//for multiplication/division results in Z reg
//can be bigger than 32 bits
//upper 32 bits Z[63:32] go to HI reg
//lower 32 bits Z[31:0] go to LO register
module register64( //same as register32, double width tho
    input wire clock,
    input wire clear,
    input wire enable,
    input wire [63:0] data_in,  
    output reg [63:0] q         
);

    always @(posedge clock) begin
        if (clear)
            q <= 64'd0; //64-bit decimal val of 0         
        else if (enable)
            q <= data_in;        
    end

endmodule