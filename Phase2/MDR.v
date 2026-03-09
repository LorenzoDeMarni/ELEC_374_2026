module MDR(
    input wire clock,
    input wire clear,
    input wire MDRin, //enable signal
    input wire Read, //choose input
    input wire [31:0] BusMuxOut, //input from bus
    input wire [31:0] Mdatain, //input from mem
    output reg [31:0] q //stored value
);

    //dual input
    //from bus for write (read=0)
    //from mem for read (read=1)

    //Phase 1: memory is simulated in the testbench
    //the testbench acts as memory and control unit
    //drives Mdatain with hardcoded instruction opcodes and data
    //sets 'read' to tell MDR when to load from 'memory'
    //generates all control signals based on the state machine
    //ex. T1 of the AND instruction, testbench sets:
    //Read = 1, 
    //Mdatain = 0x112B0000 (the AND R2,R5,R6 opcode)
    //MDRin = 1
    
    //simulates fetching the instruction from memory
    //Phase 2: MAR will connect to actual RAM/ROM modules to select memory access location

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