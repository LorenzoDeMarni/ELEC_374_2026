module pc_incrementer(
    input wire [31:0] pc_in, //current pc val
    output wire [31:0] pc_out //pc + 1
);

    assign pc_out = pc_in + 32'd1; //add 32-bit decimal w/ val 1

endmodule
