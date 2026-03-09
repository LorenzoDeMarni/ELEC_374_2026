## ELEC 374 – Phase 1 Non‑ALU Datapath Guide

This README explains **all the non‑ALU pieces** of Phase 1:

- 32‑bit and 64‑bit registers
- The 32‑bit system bus
- The MDR (memory data register)
- The PC incrementer
- How they are all wired together in `datapath.v`
- How the Phase 1 testbenches use micro‑operations and control signals

It is meant to be simple, but complete enough that you can **verbally explain the datapath** and **run simulations** in the lab.

All file paths are relative to the `Phase1/` folder.

---

## 1. Register building blocks

### 1.1 `register32` – general 32‑bit register

File: `register32.v`

```1:16:Phase1/register32.v
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
```

**Key ideas:**

- **Edge‑triggered**: Value updates only on the **positive edge of the clock**.
- **Synchronous clear**:
  - If `clear = 1` at the clock edge → output `q` becomes `0`.
- **Write enable**:
  - If `enable = 1` at the clock edge (and `clear = 0`) → `q` takes the current `BusMuxOut` value.
- If both `clear = 0` and `enable = 0`, the register **holds its previous value**.

In the datapath, `register32` is used for:

- General registers `R0`–`R15`
- `HI`, `LO`
- `PC` (program counter)
- `IR` (instruction register)
- `MAR` (memory address register)
- `Y` (ALU operand A latch)

You can describe it as:

> “`register32` is a standard 32‑bit register that can load from the system bus when its enable is high, or be cleared to zero, all on the rising edge of the clock.”

### 1.2 `register64` – 64‑bit Z register

File: `register64.v`

```1:20:Phase1/register64.v
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
```

**Key ideas:**

- Same behavior as `register32`, but with **64‑bit width**.
- Used for the **Z register**, which stores the 64‑bit ALU result.
- Supports multiply/divide results that are wider than 32 bits.
- The datapath later routes:
  - `Z[31:0]` (low 32) to `LO` or general registers.
  - `Z[63:32]` (high 32) to `HI` or onto the bus.

How to explain:

> “`register64` is just like `register32` but 64 bits wide. It serves as the Z register, holding the full 64‑bit ALU result, which we can split into high and low halves.”

---

## 2. The 32‑bit system bus

### 2.1 `bus32` – one shared bus, many sources

File: `bus32.v`

```1:39:Phase1/bus32.v
module bus32(
    //inputs from all registers to go on bus
    //only one can be active (on bus) at a time
    input wire [31:0] BusMuxIn_R0,
    input wire [31:0] BusMuxIn_R1,
    input wire [31:0] BusMuxIn_R2,
    input wire [31:0] BusMuxIn_R3,
    input wire [31:0] BusMuxIn_R4,
    input wire [31:0] BusMuxIn_R5,
    input wire [31:0] BusMuxIn_R6,
    input wire [31:0] BusMuxIn_R7,
    input wire [31:0] BusMuxIn_R8,
    input wire [31:0] BusMuxIn_R9,
    input wire [31:0] BusMuxIn_R10,
    input wire [31:0] BusMuxIn_R11,
    input wire [31:0] BusMuxIn_R12,
    input wire [31:0] BusMuxIn_R13,
    input wire [31:0] BusMuxIn_R14,
    input wire [31:0] BusMuxIn_R15,

    input wire [31:0] BusMuxIn_HI,
    input wire [31:0] BusMuxIn_LO,
    input wire [31:0] BusMuxIn_Zhigh,
    input wire [31:0] BusMuxIn_Zlow,
    input wire [31:0] BusMuxIn_PC,
    input wire [31:0] BusMuxIn_MDR,
    input wire [31:0] BusMuxIn_InPort,
    input wire [31:0] C_sign_extended,

    //control signals - tells which input (^) goes on bus
    //1 -> active, 0 -> inactive
    input wire R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, R8out, 
    R9out, R10out, R11out, R12out, R13out, R14out, R15out,
    input wire HIout, LOout, Zhighout, Zlowout,
    input wire PCout, MDRout, InPortout, Cout,

    //output (bus)
    output reg [31:0] BusMuxOut
);
```

Selection logic:

```41:68:Phase1/bus32.v
    always @(*) begin
        case (1'b1)  //find whose control signal is 1
            R0out:    BusMuxOut = BusMuxIn_R0;
            R1out:    BusMuxOut = BusMuxIn_R1;
            R2out:    BusMuxOut = BusMuxIn_R2;
            R3out:    BusMuxOut = BusMuxIn_R3;
            R4out:    BusMuxOut = BusMuxIn_R4;
            R5out:    BusMuxOut = BusMuxIn_R5;
            R6out:    BusMuxOut = BusMuxIn_R6;
            R7out:    BusMuxOut = BusMuxIn_R7;
            R8out:    BusMuxOut = BusMuxIn_R8;
            R9out:    BusMuxOut = BusMuxIn_R9;
            R10out:    BusMuxOut = BusMuxIn_R10;
            R11out:    BusMuxOut = BusMuxIn_R11;
            R12out:    BusMuxOut = BusMuxIn_R12;
            R13out:    BusMuxOut = BusMuxIn_R13;
            R14out:    BusMuxOut = BusMuxIn_R14;
            R15out:    BusMuxOut = BusMuxIn_R15;
            HIout:    BusMuxOut = BusMuxIn_HI;
            LOout:    BusMuxOut = BusMuxIn_LO;
            Zhighout: BusMuxOut = BusMuxIn_Zhigh;
            Zlowout:  BusMuxOut = BusMuxIn_Zlow;
            PCout:    BusMuxOut = BusMuxIn_PC;
            MDRout:   BusMuxOut = BusMuxIn_MDR;
            InPortout:BusMuxOut = BusMuxIn_InPort;
            Cout:     BusMuxOut = C_sign_extended;
            default:  BusMuxOut = 32'd0;
        endcase
    end
```

**Key ideas:**

- There is **one shared 32‑bit bus** (`BusMuxOut`) used to move data between registers and into the ALU.
- Many sources can potentially drive the bus:
  - General registers `R0`–`R15`
  - `HI`, `LO`
  - `Zhigh`, `Zlow`
  - `PC`, `MDR`, `InPort`, and an immediate field (`C_sign_extended`)
- The **control signals** `R0out`, `R1out`, …, `Zlowout`, `PCout`, `MDRout`, `Cout`, etc. select **exactly one source**.
- `case (1'b1)` picks the first active control signal and routes its corresponding input to the bus.

How to explain:

> “`bus32` is a big multiplexer. Only one `*_out` control signal is high at a time, and that register’s value is placed on the shared 32‑bit BusMuxOut line. All registers can read from this bus when their enable inputs are asserted.”

---

## 3. MDR – Memory Data Register

File: `MDR.v`

```1:24:Phase1/MDR.v
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
```

**Key ideas:**

- MDR can load from **two sources**:
  - The system **bus** (`BusMuxOut`).
  - The simulated **memory input** (`Mdatain`).
- The `Read` control signal chooses the source:
  - `Read = 1` → load from `Mdatain` (as if reading from memory).
  - `Read = 0` → load from the bus (as if writing a value to MDR).
- `MDRin` is the **write enable** for MDR.

In Phase 1, actual memory is not modelled; instead, testbenches directly drive `Mdatain` with constants to load registers.

How to explain:

> “MDR is a 32‑bit register that can either read from main memory (via Mdatain) or from the bus, depending on the Read signal. In Phase 1, we fake memory by driving Mdatain from the testbench.”

---

## 4. PC incrementer

File: `pc_incrementer.v`

```1:8:Phase1/pc_incrementer.v
module pc_incrementer(
    input wire [31:0] pc_in, //current pc val
    output wire [31:0] pc_out //pc + 1
);

    assign pc_out = pc_in + 32'd1; //add 32-bit decimal w/ val 1

endmodule
```

**Key ideas:**

- Pure **combinational** logic: output is always `pc_in + 1`.
- Used to implement the **“PC ← PC + 1”** micro‑operation during instruction fetch.
- In `datapath.v`, the bus chooses between `PC` and `PC_incremented` based on `IncPC`:

```85:88:Phase1/datapath.v
pc_incrementer pc_inc(
    .pc_in(PC_wire),
    .pc_out(PC_incremented)
);
```

```91:99:Phase1/datapath.v
bus32 main_bus(
    ...
    .BusMuxIn_PC(IncPC ? PC_incremented : PC_wire),
    ...
);
```

So:

- When `IncPC = 0` → the bus sees the **current PC**.
- When `IncPC = 1` → the bus sees **PC + 1**.

How to explain:

> “The PC incrementer adds 1 to the current program counter. The bus selects between PC and PC+1 using the IncPC control, so we can either read the current PC or its incremented value during instruction fetch.”

---

## 5. The datapath module (`datapath.v`)

File: `datapath.v`

This is the **top‑level Phase 1 datapath**. It wires together:

- General registers `R0`–`R15`
- Special registers `HI`, `LO`, `PC`, `IR`, `MAR`, `Y`, `Z`
- MDR
- PC incrementer
- Bus
- ALU (see separate ALU README)

### 5.1 Register instantiation

```40:62:Phase1/datapath.v
//register file instantiation (R0-R15)
wire [31:0] R0_wire, R1_wire, R2_wire, R3_wire;
wire [31:0] R4_wire, R5_wire, R6_wire, R7_wire;
wire [31:0] R8_wire, R9_wire, R10_wire, R11_wire;
wire [31:0] R12_wire, R13_wire, R14_wire, R15_wire;
wire [31:0] HI_wire, LO_wire, PC_wire, IR_wire, MAR_wire;

register32 reg_R0  (.clock(clock), .clear(clear), .enable(R0in),  .BusMuxOut(BusMuxOut), .q(R0_wire));
register32 reg_R1  (.clock(clock), .clear(clear), .enable(R1in),  .BusMuxOut(BusMuxOut), .q(R1_wire));
register32 reg_R2  (.clock(clock), .clear(clear), .enable(R2in),  .BusMuxOut(BusMuxOut), .q(R2_wire));
...
register32 reg_R15 (.clock(clock), .clear(clear), .enable(R15in), .BusMuxOut(BusMuxOut), .q(R15_wire));
    
//special registers
register32 reg_HI  (.clock(clock), .clear(clear), .enable(HIin),  .BusMuxOut(Z_reg[63:32]), .q(HI_wire));
register32 reg_LO  (.clock(clock), .clear(clear), .enable(LOin),  .BusMuxOut(Z_reg[31:0]),  .q(LO_wire));
register32 reg_PC  (.clock(clock), .clear(clear), .enable(PCin),  .BusMuxOut(BusMuxOut), .q(PC_wire));
register32 reg_IR  (.clock(clock), .clear(clear), .enable(IRin),  .BusMuxOut(BusMuxOut), .q(IR_wire));
register32 reg_MAR (.clock(clock), .clear(clear), .enable(MARin), .BusMuxOut(BusMuxOut), .q(MAR_wire));
register32 reg_Y   (.clock(clock), .clear(clear), .enable(Yin),   .BusMuxOut(BusMuxOut), .q(Y_reg));
```

Points to notice:

- General registers **always load from the bus**.
- `HI` and `LO` load from the **Z register halves** rather than from the bus (Phase 1 design choice).
- `Y` also loads from the bus and holds operand A for the ALU.

### 5.2 Z register and MDR instantiation

```72:83:Phase1/datapath.v
//64-bit Z register
register64 reg_Z (.clock(clock), .clear(clear), .enable(Zin), .data_in(ALU_result), .q(Z_reg));

MDR mdr_unit(
    .clock(clock),
    .clear(clear),
    .MDRin(MDRin),
    .Read(Read),
    .BusMuxOut(BusMuxOut),
    .Mdatain(Mdatain),
    .q(MDR_out)
);
```

- `Z` captures the ALU’s 64‑bit output when `Zin = 1`.
- MDR uses the `MDRin` and `Read` control signals as described earlier.

### 5.3 Bus wiring and ALU wiring

Bus:

```90:110:Phase1/datapath.v
//bus instantiation
bus32 main_bus(
    .BusMuxIn_R0(R0_wire),   .BusMuxIn_R1(R1_wire),   .BusMuxIn_R2(R2_wire),   .BusMuxIn_R3(R3_wire),
    .BusMuxIn_R4(R4_wire),   .BusMuxIn_R5(R5_wire),   .BusMuxIn_R6(R6_wire),   .BusMuxIn_R7(R7_wire),
    .BusMuxIn_R8(R8_wire),   .BusMuxIn_R9(R9_wire),   .BusMuxIn_R10(R10_wire), .BusMuxIn_R11(R11_wire),
    .BusMuxIn_R12(R12_wire), .BusMuxIn_R13(R13_wire), .BusMuxIn_R14(R14_wire), .BusMuxIn_R15(R15_wire),
    .BusMuxIn_HI(HI_wire),   .BusMuxIn_LO(LO_wire),
    .BusMuxIn_Zhigh(Z_reg[63:32]), .BusMuxIn_Zlow(Z_reg[31:0]),
    .BusMuxIn_PC(IncPC ? PC_incremented : PC_wire),
    .BusMuxIn_MDR(MDR_out),
    .BusMuxIn_InPort(InPort_reg),
    .C_sign_extended(C_sign_extended),
    .R0out(R0out),   .R1out(R1out),   .R2out(R2out),   .R3out(R3out),
    .R4out(R4out),   .R5out(R5out),   .R6out(R6out),   .R7out(R7out),
    .R8out(R8out),   .R9out(R9out),   .R10out(R10out), .R11out(R11out),
    .R12out(R12out), .R13out(R13out), .R14out(R14out), .R15out(R15out),
    .HIout(HIout),   .LOout(LOout),
    .Zhighout(Zhighout), .Zlowout(Zlowout),
    .PCout(PCout),   .MDRout(MDRout), .InPortout(InPortout), .Cout(Cout),
    .BusMuxOut(BusMuxOut)
);
```

ALU (for context; details in ALU README):

```112:129:Phase1/datapath.v
//ALU instantiation
ALU alu_instance(
    .A(Y_reg),
    .B(BusMuxOut),
    .AND(AND),
    .OR(OR),
    .NOT(NOT),
    .NEG(NEG),
    .ADD(ADD),
    .SUB(SUB),
    .MUL(MUL),
    .DIV(DIV),
    .SHR(SHR),
    .SHRA(SHRA),
    .SHL(SHL),
    .ROR(ROR),
    .ROL(ROL),
    .result(ALU_result)
);
```

Other notes:

- `InPort_reg` and `C_sign_extended` are placeholders in Phase 1:

```132:136:Phase1/datapath.v
//InPort register (placeholder for phase 2)
assign InPort_reg = 32'd0;
    
//C sign extension (placeholder - extract from IR in Phase 2)
assign C_sign_extended = 32'd0;
```

So for Phase 1 you can say:

> “Our datapath has a 32‑bit shared bus connecting all the registers, an MDR that simulates memory loads via Mdatain, and a Z register that captures the ALU’s 64‑bit output. Control signals like R5out, R2in, Yin, Zin, and PCout tell us which registers drive or sample the bus on each clock edge.”

---

## 6. Phase 1 testbenches and micro‑operations

Each `_tb.v` file (like `and_tb.v`, `add_tb.v`, `sub_tb.v`, `mul_tb.v`, `shra_tb.v`, etc.) does three things:

1. **Instantiates `datapath`** as the device under test.
2. **Defines a simple finite state machine** (states `Default`, `Reg_loadXa`, `Reg_loadXb`, `T0`, `T1`, …).
3. **Implements control logic** in an `always @(Present_state)` block to:
   - Load initial register values using MDR + bus + register enables.
   - Step through the micro‑operations to perform one instruction (e.g., AND, ADD, SUB, MUL, SHRA).
   - Capture results and print them with `$display`.

Example: `and_tb.v` micro‑operations:

- **Reg_load1a / Reg_load1b**: Load constant into R5 via Mdatain → MDR → bus → R5.
- **Reg_load2a / Reg_load2b**: Load constant into R6.
- **Reg_load3a / Reg_load3b**: Load constant into R2 (to be overwritten).
- **T0**: Instruction fetch part 1 (`MAR ← PC`, `PC ← PC + 1` via `IncPC` and `Zin`).
- **T1**: Instruction fetch part 2 (`PC ← Zlow`, load instruction into IR via MDR).
- **T2**: `IR ← MDR`.
- **T3**: `Y ← R5`.
- **T4**: ALU operation (`Z ← R5 AND R6` using bus + AND + Zin).
- **T5**: Write result (`R2 ← Zlow`).

They all follow the same pattern, but change:

- Which registers are used (`R0`, `R1`, `R3`, `R7`, etc.).
- Which ALU control signal is asserted (`AND`, `ADD`, `SUB`, `MUL`, `SHRA`, etc.).
- Where the result is written (general register or `HI`/`LO`).

In waveforms, you can point to:

- Rising edges of `clock`.
- State changes of `Present_state`.
- Which `*_out` and `*_in` signals are asserted at each step.
- Changes in `BusMuxOut`, `Y`, `Z`, and register outputs.

---

## 7. How to run Phase 1 datapath tests

The compile/run procedure is the same pattern for all operation testbenches.

From the **project root**, do:

```bash
cd Phase1
```

### 7.1 Example: AND testbench

```bash
iverilog -o and_tb.out \
  and_tb.v datapath.v ALU.v adder.v boothmultiplication.v NRDivider.v \
  register32.v register64.v bus32.v MDR.v pc_incrementer.v

vvp and_tb.out
gtkwave and.vcd &
```

You will see `$display` lines showing the initial register values and the final result, plus an `and.vcd` waveform file.

### 7.2 Example: SUB, MUL, SHRA, etc.

Just change the testbench filename and the VCD name:

```bash
# SUB
iverilog -o sub_tb.out \
  sub_tb.v datapath.v ALU.v adder.v boothmultiplication.v NRDivider.v \
  register32.v register64.v bus32.v MDR.v pc_incrementer.v
vvp sub_tb.out
gtkwave sub.vcd &

# MUL
iverilog -o mul_tb.out \
  mul_tb.v datapath.v ALU.v adder.v boothmultiplication.v NRDivider.v \
  register32.v register64.v bus32.v MDR.v pc_incrementer.v
vvp mul_tb.out
gtkwave mul.vcd &

# SHRA
iverilog -o shra_tb.out \
  shra_tb.v datapath.v ALU.v adder.v boothmultiplication.v NRDivider.v \
  register32.v register64.v bus32.v MDR.v pc_incrementer.v
vvp shra_tb.out
gtkwave shra.vcd &
```

You can use the same module list (`datapath.v`, `ALU.v`, `adder.v`, `boothmultiplication.v`, `NRDivider.v`, `register32.v`, `register64.v`, `bus32.v`, `MDR.v`, `pc_incrementer.v`) for all Phase 1 datapath tests.

---

## 8. Short summary lines for non‑ALU pieces

These are quick one‑liners you can use in the lab:

- **`register32`**: “32‑bit edge‑triggered register that loads from the bus when enable is 1, or clears to zero when clear is 1.”
- **`register64` (Z)**: “64‑bit version of the register used for Z, capturing the full 64‑bit ALU result so we can use HI and LO.”
- **`bus32`**: “A big multiplexer that selects exactly one register or source to drive the 32‑bit system bus based on `*_out` control signals.”
- **`MDR`**: “Memory Data Register that can either take data from simulated memory (Mdatain) when Read=1 or from the bus when Read=0.”
- **`pc_incrementer`**: “Combinational logic that outputs PC+1; the bus sees either PC or PC+1 depending on the IncPC control.”
- **`datapath`**: “Top‑level wiring that connects all registers, bus, MDR, PC incrementer, and the ALU; the testbenches drive its control signals to implement each instruction as a sequence of micro‑operations.”

Together with the ALU README, this gives you full coverage of **all Phase 1 components** and how to demonstrate them. 

