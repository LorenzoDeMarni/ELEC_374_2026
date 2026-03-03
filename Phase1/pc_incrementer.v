module pc_incrementer(
    input wire [31:0] pc_in,  // current PC value
    output wire [31:0] pc_out // PC + 1
);

    // PC incrementer: computes PC + 1 as required by the spec
    assign pc_out = pc_in + 32'd1;

endmodule

// Combinational adder that continuously computes PC+1
// When IncPC control signal is high, the incremented value goes to the bus instead of the current PC
// This is used in T0 during instruction fetch; in T1, the incremented value is written back to PC