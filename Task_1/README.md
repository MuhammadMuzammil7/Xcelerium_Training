# Task 1 – Combinational Logic Modules

This folder contains **Task 1** of the Xcelerium Training, which focuses on the design and verification of **fundamental combinational digital circuits** using SystemVerilog.

Each subfolder represents an independent design with its corresponding testbench for functional verification.

---

## Folder Structure
```
Task_1/
│
├── 32_Bit_Adder/
│ ├── adder32.sv
│ └── adder32_tb.sv
│
├── Barrel_Shifter/
│ ├── barrel_shifter.sv
│ └── barrel_shifter_tb.sv
│
└── Priority_Encoder/
├── encoder8to3.sv
└── encoder8to3_tb.sv
```

---

## Module Description

### 32-bit Adder
The 32-bit adder module performs addition of two 32-bit operands along with an optional carry-in. It produces a 32-bit sum
and a carry-out, allowing it to handle arithmetic operations that exceed the 32-bit range. 

**Files:**
- `adder32.sv` – DUT
- `adder32_tb.sv` – Testbench

---

### Barrel Shifter
The barrel shifter module performs efficient left or right shifts on a 32-bit input vector. The shift amount is specified
using a 5-bit input, allowing shifts from 0 to 31 positions, while the direction input selects between left and right shifting.

**Files:**
- `barrel_shifter.sv` – DUT
- `barrel_shifter_tb.sv` – Testbench

---

### Priority Encoder
The 8-to-3 priority encoder module takes an 8-bit input vector and outputs the binary index of the highest-priority active
input. It also provides a `valid` signal indicating whether any input is high. The module checks inputs starting from the 
most significant bit down to the least significant bit, and if none are active, the output defaults to 0 and `valid` is set 
low. This module is useful for selecting the highest-priority signal in combinational logic circuits.

**Files:**
- `encoder8to3.sv` – DUT
- `encoder8to3_tb.sv` – Testbench

---

