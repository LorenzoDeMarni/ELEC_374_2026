module pc_incrementer(
    input wire [31:0] pc_in, //current pc val
    output wire [31:0] pc_out //pc + 1
);

    assign pc_out = pc_in + 32'd1; //add 32-bit decimal w/ val 1

endmodule

//combinational adder that continuously computes PC+1
//when IncPC control signal is high, the incremented value goes to the bus instead of the current PC
//happens in T0 to calculate the next instruction address
//then stored in Z and then loaded back to PC in T1