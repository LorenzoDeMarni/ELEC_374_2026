## ELEC 374 – Phase 1 ALU Guide

This document explains **everything you need to know about the Phase 1 ALU** and how to **run simulations** to demonstrate each operation in the lab.

The goal is that you can:
- **Explain clearly** what every ALU operation does.
- **Describe how it is implemented** in hardware (at a simple level).
- **Show it working** using the provided Verilog testbenches.

All file paths in this document are relative to the `Phase1/` folder.

---

## 1. Big picture: where the ALU lives

- **Datapath module**: `datapath.v`
- **ALU module**: `ALU.v`

In the datapath, the ALU is instantiated like this:

```112:130:Phase1/datapath.v
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

- **Operand A** to the ALU is the `Y` register (`Y_reg`).
- **Operand B** is the value currently on the **system bus** (`BusMuxOut`).
- The ALU output is a **64‑bit value** `ALU_result`, which is stored in the **64‑bit Z register**.
  - `Z[31:0]` (low half) is used for normal 32‑bit results.
  - `Z[63:32]` (high half) is used for upper bits of multiply result or for remainder of division.
  - `HI` and `LO` can later take values from the high and low halves of `Z`.

You should be able to say in lab:

> “The ALU takes operand A from the `Y` register and operand B from the main bus. It writes a 64‑bit result into the `Z` register, and then micro‑operations move the low or high half of `Z` into the appropriate destination registers (like `R2`, `HI`, or `LO`).”

---

## 2. ALU interface and selection

The ALU’s interface in `ALU.v`:

```1:6:Phase1/ALU.v
module ALU(
    input wire [31:0] A, B,
    input wire AND, OR, NOT, NEG,
    input wire ADD, SUB, MUL, DIV,
    input wire SHR, SHRA, SHL, ROR, ROL,
    output reg [63:0] result
);
```

- **Inputs**:
  - `A` – 32‑bit operand from `Y` register.
  - `B` – 32‑bit operand from bus.
  - One‑hot **control signals**: `AND`, `OR`, `NOT`, `NEG`, `ADD`, `SUB`, `MUL`, `DIV`, `SHR`, `SHRA`, `SHL`, `ROR`, `ROL`.
- **Output**:
  - `result` – 64‑bit ALU output.

Only **one control signal** should be `1` at a time. Inside the ALU, all candidate results are computed in parallel, and then the correct one is selected:

```36:64:Phase1/ALU.v
always @(*) begin
    if (AND)
        result = {32'd0, and_result};
    else if (OR)
        result = {32'd0, or_result};
    else if (NOT)
        result = {32'd0, not_result};
    else if (ADD)
        result = {32'd0, add_result};
    else if (SUB)
        result = {32'd0, sub_result};
    else if (MUL)
        result = mul_result;  // Full 64-bit
    else if (DIV)
        result = {div_remainder, div_quotient};  // Upper: remainder, Lower: quotient
    else if (NEG)
        result = {32'd0, neg_result};
    else if (SHR)
        result = {32'd0, shift_right_result};
    else if (SHRA)
        result = {32'd0, shift_right_arithmetic_result};
    else if (SHL)
        result = {32'd0, shift_left_result};
    else if (ROR)
        result = {32'd0, rotate_right_result};
    else if (ROL)
        result = {32'd0, rotate_left_result};
    else
        result = 64'd0;
end
```

Key points you should remember:

- **Normal 32‑bit ops** (AND, OR, NOT, NEG, ADD, SUB, shifts, rotates) put their 32‑bit result in **`result[31:0]`**, with the **upper 32 bits zero**.
- **MUL** uses the **full 64‑bit product**.
- **DIV** encodes **remainder in the upper 32 bits** and **quotient in the lower 32 bits**.

---

## 3. Logical operations

All logical operations are **bitwise**, applied to each bit independently.

### 3.1 AND

- **Control signal**: `AND = 1`
- **Expression**: `and_result = A & B;`

```15:18:Phase1/ALU.v
assign and_result = A & B;
```

- **Meaning**: For each bit \(i\), `and_result[i]` is `1` only if **both** `A[i]` and `B[i]` are `1`.
- **Output**: `result = {32'd0, and_result};` – low 32 bits hold the AND; upper 32 bits are zero.

How to explain:
> “AND takes the two operands and produces 1s only where both bits were 1; everything else becomes 0.”

### 3.2 OR

- **Control signal**: `OR = 1`
- **Expression**: `or_result = A | B;`

```16:18:Phase1/ALU.v
assign or_result = A | B;
```

- **Meaning**: For each bit \(i\), `or_result[i]` is `1` if **either** `A[i]` or `B[i]` is `1`.

### 3.3 NOT

- **Control signal**: `NOT = 1`
- **Expression**: `not_result = ~A;`

```17:19:Phase1/ALU.v
assign not_result = ~A;
```

- **Meaning**: Bitwise inversion of `A`. Each `0` becomes `1`, and each `1` becomes `0`.
- **Note**: `B` is ignored for NOT.

### 3.4 NEG (two’s complement negate)

- **Control signal**: `NEG = 1`
- **Expression**: `neg_result = -A;`

```18:20:Phase1/ALU.v
assign neg_result = -A;
```

- **Meaning**: Computes the **two’s‑complement negative** of `A`.
- Conceptually: \( -A = \text{~A} + 1 \) in two’s complement.

How to explain:
> “NEG interprets A as a signed integer and flips its sign using two’s‑complement arithmetic.”

---

## 4. Addition and subtraction

### 4.1 ADD – ripple‑carry adder

ADD uses a custom **32‑bit ripple‑carry adder** defined in `adder.v`:

```27:29:Phase1/ALU.v
adder add_instance(A, B, add_result);
assign neg_B = -B;
adder sub_instance(A, neg_B, sub_result);
```

Adder implementation:

```1:19:Phase1/adder.v
module adder(A, B, Result);

input [31:0] A, B;
output [31:0] Result;

reg [31:0] Result;
reg [32:0] LocalCarry;
integer i;

always@(A or B)
    begin
        LocalCarry = 33'd0;
        for(i = 0; i < 32; i = i + 1)
        begin
                Result[i] = A[i]^B[i]^LocalCarry[i];
                LocalCarry[i+1] = (A[i]&B[i])|(LocalCarry[i]&(A[i]|B[i]));
        end
end
endmodule
```

What this means:

- The adder processes **one bit at a time** (from bit 0 to bit 31).
- Each bit uses a **full‑adder** equation:
  - Sum bit = XOR of A, B, and carry‑in.
  - Next carry = 1 if at least two of the three inputs are 1.
- The final result is a standard 32‑bit sum `A + B`.

How to say it:
> “ADD uses a 32‑bit ripple‑carry adder that adds A and B one bit at a time, passing a carry from the least‑significant bit up to the most‑significant bit.”

### 4.2 SUB – implemented as A + (−B)

- **Control signal**: `SUB = 1`
- **Implementation**:
  - First compute `neg_B = -B;`
  - Then use the **same ripple‑carry adder** as ADD:

```27:29:Phase1/ALU.v
adder add_instance(A, B, add_result);
assign neg_B = -B;
adder sub_instance(A, neg_B, sub_result);
```

So:

- `sub_result = A + (-B)` which is equivalent to `A - B` in two’s‑complement arithmetic.

How to explain:
> “SUB works by negating the second operand using two’s‑complement and then running the same adder, so it effectively does A + (−B).”

---

## 5. Shifts and rotates

All shift and rotate operations use the **lower 5 bits of B** (`B[4:0]`) as the **shift amount**. That means the shift amount is always between 0 and 31.

```21:26:Phase1/ALU.v
// Shifts and rotates (use B[4:0] for 32-bit shift amounts)
assign shift_left_result = A << B[4:0];
assign shift_right_result = A >> B[4:0];
assign shift_right_arithmetic_result = $signed(A) >>> B[4:0];
assign rotate_left_result = (A << B[4:0]) | (A >> (32 - B[4:0]));
assign rotate_right_result = (A >> B[4:0]) | (A << (32 - B[4:0]));
```

### 5.1 SHL – logical left shift

- **Control signal**: `SHL = 1`
- **Expression**: `shift_left_result = A << B[4:0];`
- **Behavior**:
  - Bits are shifted **towards more significant positions**.
  - Bits that fall off the left end are discarded.
  - New bits entering on the right are all **0**.
  - Sign is not preserved; this is a **logical** shift.

How to say it:
> “SHL shifts A left by the amount in the lower 5 bits of B, filling in zeros on the right.”

### 5.2 SHR – logical right shift

- **Control signal**: `SHR = 1`
- **Expression**: `shift_right_result = A >> B[4:0];`
- **Behavior**:
  - Bits are shifted **towards less significant positions**.
  - Bits that fall off the right end are discarded.
  - New bits entering on the left are all **0**.
  - Does **not** preserve sign; this is logical.

How to say it:
> “SHR shifts A right and always inserts zeros at the left, ignoring the sign bit.”

### 5.3 SHRA – arithmetic right shift

- **Control signal**: `SHRA = 1`
- **Expression**: `shift_right_arithmetic_result = $signed(A) >>> B[4:0];`
- **Behavior**:
  - Treats `A` as a **signed** 32‑bit number.
  - Shifts bits to the right.
  - New bits entering on the left copy the **sign bit** (bit 31 of A).
  - This approximately divides by \(2^{\text{shift amount}}\) while preserving sign.

How to say it:
> “SHRA treats A as signed and shifts right while copying the sign bit, so negative numbers stay negative after the shift.”

The `shra_tb.v` testbench demonstrates this with an example.

### 5.4 ROL – rotate left

- **Control signal**: `ROL = 1`
- **Expression**: `rotate_left_result = (A << B[4:0]) | (A >> (32 - B[4:0]));`
- **Behavior**:
  - Bits that fall off the **left** end are **wrapped around** to the **right**.
  - No bits are discarded; it is a pure bit rotation.
  - No concept of sign; just rotates the 32‑bit pattern.

### 5.5 ROR – rotate right

- **Control signal**: `ROR = 1`
- **Expression**: `rotate_right_result = (A >> B[4:0]) | (A << (32 - B[4:0]));`
- **Behavior**:
  - Bits that fall off the **right** end are wrapped around to the **left**.
  - Again, no bits are lost and no zeros or sign bits are inserted.

How to say it:
> “ROL and ROR are circular shifts. They don’t insert zeros or sign bits; they just rotate the 32 bits around like a ring.”

---

## 6. Multiplication (MUL) – signed Booth multiplier

- **Control signal**: `MUL = 1`
- **Module used**: `booth_multiplier` in `boothmultiplication.v`.

ALU connection:

```31:32:Phase1/ALU.v
booth_multiplier mul_instance(A, B, mul_result);
```

Booth multiplier interface:

```1:5:Phase1/boothmultiplication.v
module booth_multiplier (
    input  signed [31:0] multiplicand,
    input  signed [31:0] multiplier,
    output signed [63:0] product
);
```

Core algorithm:

```10:22:Phase1/boothmultiplication.v
always @(*) begin
    // Initialize: Upper 32 bits 0, lower bits multiplier, extra bit 0
    temp_P = {32'd0, multiplier, 1'b0}; 

    for (i = 0; i < 32; i = i + 1) begin
        case (temp_P[1:0])
            2'b01: temp_P[64:33] = temp_P[64:33] + multiplicand;
            2'b10: temp_P[64:33] = temp_P[64:33] - multiplicand;
            default: ;
        endcase
        // Arithmetic Right Shift
        temp_P = {temp_P[64], temp_P[64:1]};
    end
end

assign product = temp_P[64:1]; 
```

What to remember:

- This is a **signed** 32‑bit by 32‑bit **Booth multiplier**.
- It builds a 65‑bit value `temp_P` containing:
  - An accumulator (upper 32 bits),
  - The multiplier (next 32 bits),
  - An extra bit (`Q‑1`) at the LSB.
- On each iteration, it:
  - Looks at the **two lowest bits** (`Q0` and `Q‑1`):
    - `01` → add multiplicand.
    - `10` → subtract multiplicand.
    - `00`/`11` → do nothing.
  - Then does an **arithmetic right shift** of the whole register (preserving sign).
- After 32 iterations, the product is in `temp_P[64:1]`, assigned to `product`.

ALU behavior when `MUL = 1`:

- `result = mul_result;` – **all 64 bits** of the multiplication are returned.
- Low 32 bits can go to `LO`, high 32 bits can go to `HI` (see `mul_tb.v`).

How to say it:
> “MUL is a signed Booth multiplier. It repeatedly examines pairs of bits of the multiplier and conditionally adds or subtracts the multiplicand into an accumulator with an arithmetic right shift, producing a full 64‑bit product. We store the low 32 bits in LO and the high 32 bits in HI.”

---

## 7. Division (DIV) – signed non‑restoring divider

- **Control signal**: `DIV = 1`
- **Module used**: `NRDivider` in `NRDivider.v`.

ALU connection:

```33:34:Phase1/ALU.v
wire [31:0] div_quotient, div_remainder;
NRDivider div_instance(A, B, div_quotient, div_remainder);
```

Divider interface:

```1:6:Phase1/NRDivider.v
module NRDivider(
    input signed [31:0] dividend,
    input signed [31:0] divisor,
    output reg signed [31:0] quotient,
    output reg signed [31:0] remainder
);
```

Main logic:

```13:43:Phase1/NRDivider.v
always @(*) begin
    if(divisor == 0) begin
        quotient  = 32'sd0;
        remainder = 32'sd0;
    end
    else begin
        A_abs = (dividend < 0) ? -dividend : dividend;
        B_abs = (divisor < 0) ? -divisor : divisor;
        sign_q = dividend[31] ^ divisor[31]; // Sign bit is now bit 31

        rem = 32'sd0;
        q = 32'd0;
        for (i = 31; i >= 0; i = i - 1) begin
            // Shift left remainder, add next bit of A_abs
            rem = {rem[31:0], A_abs[i]};
            if (rem >= 0)
                rem = rem - B_abs;
            else
                rem = rem + B_abs;
            if (rem >= 0)
                q[i] = 1'b1;
            else
                q[i] = 1'b0;
        end

        if (rem < 0)
            rem = rem + B_abs;

        quotient  = sign_q ? -q : q;
        remainder = (dividend < 0) ? -rem[31:0] : rem[31:0];
    end
end
```

What to remember:

- It implements **signed non‑restoring division**.
- It divides `dividend` by `divisor`:
  - Works on **absolute values** during the loop.
  - Builds quotient bits from MSB down to LSB.
  - Keeps a signed remainder register `rem` that is updated by subtracting or adding the divisor.
  - Fixes signs of quotient and remainder at the end.
- Division by zero returns quotient and remainder **0**.

ALU behavior when `DIV = 1`:

```47:50:Phase1/ALU.v
else if (DIV)
    result = {div_remainder, div_quotient};  // Upper: remainder, Lower: quotient
```

- `result[31:0]` = **quotient**.
- `result[63:32]` = **remainder**.

How to explain:
> “DIV uses a signed non‑restoring division algorithm. It iteratively shifts in bits of the dividend and subtracts or adds the absolute divisor to decide each quotient bit, then applies the correct sign to the quotient and remainder. The ALU packs the remainder in the top 32 bits and the quotient in the bottom 32 bits of the 64‑bit result.”

---

## 8. How ALU results move through the datapath

Important registers:

- `Y` – holds operand A for the ALU.
- `BusMuxOut` – holds operand B from the bus.
- `Z` – 64‑bit register that stores the **ALU result**.
- `HI`, `LO`, and general registers `R0`–`R15` – can receive values from `Z`.

Typical sequence for a register‑register operation (e.g., `ADD R2, R5, R6`):

1. **Load operands into registers**:
   - Testbenches first load values into `R5` and `R6` via `MDR` and the bus.
2. **Move first source to Y**:
   - Assert `R5out = 1`, `Yin = 1` → `R5` value is put on the bus and stored in `Y`.
3. **Perform ALU operation**:
   - Assert `R6out = 1` to put `R6` on the bus.
   - Assert the correct ALU control signal (e.g., `ADD = 1`).
   - Assert `Zin = 1` so the ALU output is captured into `Z`.
4. **Write result back**:
   - Assert `Zlowout = 1` to put `Z[31:0]` on the bus.
   - Assert `R2in = 1` to store that value into `R2`.

You can see this pattern in the various `_tb.v` files (e.g., `add_tb.v`, `sub_tb.v`, `mul_tb.v`, `shra_tb.v`).

In the lab, you can describe it like this:

> “To execute an operation like ADD R2,R5,R6, the control logic first loads R5 into the Y register, then puts R6 on the bus and asserts ADD so the ALU computes Y + bus. That 32‑bit result is captured into the Z register, and then Z’s low half is written back into R2.”

---

## 9. Running simulations (Icarus Verilog + GTKWave)

The project is set up to use **Icarus Verilog** (`iverilog`) and **GTKWave** for waveforms.

Make sure you have:

- `iverilog` installed (on Ubuntu: `sudo apt install iverilog`).
- `gtkwave` installed for viewing waveforms (on Ubuntu: `sudo apt install gtkwave`).

All commands below assume you are in the **project root** and then `cd` into `Phase1`.

### 9.1 General compile + run pattern

Each operation has a testbench like `add_tb.v`, `sub_tb.v`, `mul_tb.v`, etc., which instantiates `datapath`.

To simulate a testbench:

1. **Change into Phase1**:

```bash
cd Phase1
```

2. **Compile** (example: ADD testbench):

```bash
iverilog -o add_tb.out \
  add_tb.v datapath.v ALU.v adder.v boothmultiplication.v NRDivider.v \
  register32.v register64.v bus32.v MDR.v pc_incrementer.v
```

3. **Run the simulation**:

```bash
vvp add_tb.out
```

This will:
- Print `$display` lines to the terminal showing register values and expected results.
- Produce a VCD waveform file, e.g. `add.vcd`, specified by `$dumpfile` in the testbench.

4. **View waveforms with GTKWave (optional but great for demos)**:

```bash
gtkwave add.vcd &
```

Repeat the same pattern for other operations, changing the filenames:

- `sub_tb.v` → `sub_tb.out`, `sub.vcd`
- `mul_tb.v` → `mul_tb.out`, `mul.vcd`
- `shra_tb.v` → `shra_tb.out`, `shra.vcd`
- and similarly for `and_tb.v`, `or_tb.v`, `shl_tb.v`, `shr_tb.v`, `ror_tb.v`, `rol_tb.v`, `neg_tb.v`, `not_tb.v`, `div_tb.v`, etc.

You can reuse the same module list (`datapath.v`, `ALU.v`, etc.) for all of them.

### 9.2 What to show your TA in the waveforms

In GTKWave, add these signals to the waveform:

- **Registers**: `R0`–`R15`, `HI`, `LO`, `Y`, `Z`.
- **ALU inputs**: `Y`, `BusMuxOut_signal`.
- **ALU control signals**: `AND`, `OR`, `NOT`, `NEG`, `ADD`, `SUB`, `MUL`, `DIV`, `SHR`, `SHRA`, `SHL`, `ROR`, `ROL`.
- **Clock and state**: `clock`, `Present_state` (inside the testbench).

Then you can step through the times (`T0`, `T1`, …) and explain:

- When each register is loaded.
- When `Y` captures its value.
- When the ALU control signal goes high and `Zin` is asserted.
- When the result is written back into a destination register (e.g., `R2in = 1`, or `HIin`/`LOin = 1`).

This connects the **control sequence** to the **ALU operation** you’re describing.

---

## 10. Short “sound‑bite” explanations for each ALU op

These are quick sentences you can memorize and use in the lab:

- **AND**: “Bitwise AND; each output bit is 1 only where both inputs have 1, result lives in the low 32 bits of Z.”
- **OR**: “Bitwise OR; each output bit is 1 if either input bit is 1.”
- **NOT**: “Bitwise invert of A; B is ignored, and we flip every bit of A.”
- **NEG**: “Two’s‑complement negate of A; we interpret A as signed and compute −A.”
- **ADD**: “32‑bit ripple‑carry addition; we add A and B one bit at a time and store the sum in Z’s low 32 bits.”
- **SUB**: “Subtraction implemented as A plus the two’s‑complement of B, using the same adder as ADD.”
- **MUL**: “Signed Booth multiplier; produces a full 64‑bit product from A and B, with low 32 bits in LO and high 32 bits in HI.”
- **DIV**: “Signed non‑restoring division; quotient in the low 32 bits of Z and remainder in the high 32 bits.”
- **SHL**: “Logical shift left of A by the lower 5 bits of B, filling zeros on the right.”
- **SHR**: “Logical shift right of A by the lower 5 bits of B, filling zeros on the left.”
- **SHRA**: “Arithmetic right shift of A by the lower 5 bits of B, copying the sign bit so negatives stay negative.”
- **ROL**: “Rotate left; we circularly shift A left by B[4:0], wrapping bits that fall off the MSB back into the LSB.”
- **ROR**: “Rotate right; circular shift A right by B[4:0], wrapping bits that fall off the LSB back into the MSB.”

If you can comfortably say these sentences and show the corresponding waveforms, you will be in very good shape for your Phase 1 ALU questions and demos.
