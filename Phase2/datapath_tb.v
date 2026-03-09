`timescale 1ns/10ps
module datapath_tb;

  reg Clock, Clear; // add any other signals to see in your simulation
  reg PCout, Zlowout, MDRout, R5out, R6out;
  reg R2in, R5in, R6in, MARin, Zin, PCin, MDRin, IRin, Yin;
  reg IncPC, Read, AND;

  reg [31:0] Mdatain;

  // corrected quotation marks in parameters
  parameter Default = 4'b0000, Reg_load1a = 4'b0001, Reg_load1b = 4'b0010, 
            Reg_load2a = 4'b0011, Reg_load2b = 4'b0100, Reg_load3a = 4'b0101, 
            Reg_load3b = 4'b0110, T0 = 4'b0111, T1 = 4'b1000, T2 = 4'b1001, 
            T3 = 4'b1010, T4 = 4'b1011, T5 = 4'b1100;

  reg [3:0] Present_state = Default;

  // instantiate the datapath
  datapath DUT(
    .clock(Clock),
    .clear(Clear),

    // register control signals (in)
    .R2in(R2in), .R5in(R5in), .R6in(R6in),
    .PCin(PCin), .MARin(MARin), .MDRin(MDRin), .IRin(IRin), .Yin(Yin),
    
    // register control signals (out)
    .R5out(R5out), .R6out(R6out), 
    .PCout(PCout), .Zlowout(Zlowout), .MDRout(MDRout),
    
    // ALU control signals
    .IncPC(IncPC), .AND(AND),
    
    // memory interface
    .Read(Read),
    .Mdatain(Mdatain),
    
    // outputs for monitoring
    .R0(), .R1(), .R2(), .R3(),
    .R4(), .R5(), .R6(), .R7(),
    .R8(), .R9(), .R10(), .R11(),
    .R12(), .R13(), .R14(), .R15(),
    .HI(), .LO(), .PC_out(), .IR(), .MAR(),
    .Y(), .Z(), .BusMuxOut_signal()
  );

  // add test logic here
  initial begin
    Clock = 0;
    Clear = 1;
    #20 Clear = 0;
    forever #10 Clock = ~Clock;
  end

  // finite state machine; if clock rising-edge
  always @(posedge Clock) begin
    case (Present_state)
      Default   : Present_state = Reg_load1a;
      Reg_load1a: Present_state = Reg_load1b;
      Reg_load1b: Present_state = Reg_load2a;
      Reg_load2a: Present_state = Reg_load2b;
      Reg_load2b: Present_state = Reg_load3a;
      Reg_load3a: Present_state = Reg_load3b;
      Reg_load3b: Present_state = T0;
      T0        : Present_state = T1;
      T1        : Present_state = T2;
      T2        : Present_state = T3;
      T3        : Present_state = T4;
      T4        : Present_state = T5;
      T5        : Present_state = Default;
      default   : Present_state = Default; // safety
    endcase
  end

  // do the required job in each state
  always @(posedge Clock) begin
    // assert the required signals in each clock cycle
    // all signals are reset at start of each cycle
    PCout <= 0; Zlowout <= 0; MDRout <= 0; 
    R5out <= 0; R6out <= 0; MARin <= 0; Zin <= 0;
    PCin <= 0; MDRin <= 0; IRin <= 0; Yin <= 0;
    IncPC <= 0; Read <= 0; AND <= 0;
    R2in <= 0; R5in <= 0; R6in <= 0; Mdatain <= 32'h00000000;

    case (Present_state)
      Default: begin
        // initialize the signals
      end

      Reg_load1a: begin
        Mdatain <= 32'h00000034;
        Read <= 1; MDRin <= 1;
      end

      Reg_load1b: begin
        MDRout <= 1; R5in <= 1;
      end

      Reg_load2a: begin
        Mdatain <= 32'h00000045;
        Read <= 1; MDRin <= 1;
      end

      Reg_load2b: begin
        MDRout <= 1; R6in <= 1;
      end

      Reg_load3a: begin
        Mdatain <= 32'h00000067;
        Read <= 1; MDRin <= 1;
      end

      Reg_load3b: begin
        MDRout <= 1; R2in <= 1;
      end

      T0: begin
        // Instruction fetch part 1: MAR <- PC, PC <- PC + 1
        PCout <= 1;
        IncPC <= 1;   // bus sees PC + 1
        MARin <= 1;   // MAR captures PC (or PC+1 depending on design)
        PCin  <= 1;   // PC captures PC + 1 from bus
      end

      T1: begin
        // Instruction fetch part 2: IR <- MDR (via memory)
        Read   <= 1;
        MDRin  <= 1;
        Mdatain <= 32'h112B0000; // opcode for “and R2, R5, R6”
      end

      T2: begin
        MDRout <= 1; IRin <= 1;
      end

      T3: begin
        R5out <= 1; Yin <= 1;
      end

      T4: begin
        R6out <= 1; AND <= 1; Zin <= 1;
      end

      T5: begin
        Zlowout <= 1; R2in <= 1;
      end
    endcase
  end

  // Add simulation termination
  initial begin
    $dumpfile("datapath.vcd");
    $dumpvars(0, datapath_tb);
    #500;  // Wait for simulation to complete
    $display("Simulation complete");
    $finish;
  end

endmodule