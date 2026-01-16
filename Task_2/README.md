## Task 2 - Sequential Circuit Design

This folder contains Task 2 of the Xcelerium Training, which focuses on the design and verification of fundamental sequential 
and arithmetic digital circuits using SystemVerilog.

 Each subfolder represents an independent design with its corresponding testbench for functional verification.

---

## Folder Structure
```
Task_2/
│
├── Adder_Tree_Multiplier/
│   ├── adder_tree_mult.sv
│   └── adder_tree_mult_tb.sv
│
├── Array_Multiplier/
│   ├── androw.sv
│   ├── adderrow.sv
│   ├── mult_row.sv
│   ├── multiplier.sv
│   └── multiplier_tb.sv
│
├── Counter/
│   ├── counter.sv
│   └── counter_tb.sv
│
├── Register/
│   ├── register32.sv
│   └── register32_tb.sv
│
└── Shift_Register/
    ├── shift_reg.sv
    └── shift_reg_tb.sv
```

---

## Module Description

### Adder Tree Multiplier
The adder tree multiplier implements an 8-bit by 8-bit multiplication using a structured partial-product and adder-tree approach.
The inputs are first registered, after which partial products are generated and summed hierarchically using a multi-level adder 
tree. The final multiplication result is registered at the output, making this design suitable for synchronous digital systems.

**Files:**
- `adder_tree_mult.sv` – DUT
- `adder_tree_mult_tb.sv` – Testbench

---

### Array Multiplier
The array multiplier implements an 8-bit by 8-bit multiplication using a structured, row-by-row hardware architecture. Partial 
products are generated for each bit of the multiplier and accumulated through cascaded adder stages, forming a regular and 
scalable array structure. This design demonstrates how basic arithmetic blocks such as AND logic and adders can be combined to 
realize a complete multiplication unit, making it suitable for understanding hardware-based multiplication and data-path design.

**Files:**
- `androw.sv` – Partial product generation block
- `adderrow.sv` – Adder row used for accumulation
- `mult_row.sv` – Combined AND and adder row
- `multiplier.sv` – Top-level DUT
- `multiplier_tb.sv` – Testbench

---

### Up-Down Counter
The up-down counter module implements an 8-bit synchronous counter capable of counting either upward or downward based on a 
control signal. Counting is enabled through an explicit enable input, and the counter supports asynchronous reset. This module
is commonly used in control logic, sequencing, and timing-related applications.

**Files:**
- `counter.sv` – DUT
- `counter_tb.sv` – Testbench

---

### 32-bit Register
The 32-bit register module stores a 32-bit data word and updates its contents synchronously based on a load control signal. 
It supports reset functionality and is intended for use in data-path designs where controlled data storage is required. This 
module represents a basic sequential storage element in digital systems.

**Files:**
- `register32.sv` – DUT
- `register32_tb.sv` – Testbench

---

### Shift Register
The shift register module provides serial data shifting functionality with a configurable width. Depending on the direction 
control signal, data can be shifted left or right when enabled. This module is useful for data serialization, bit manipulation,
and intermediate storage in sequential digital designs.

**Files:**
- `shift_reg.sv` – DUT
- `shift_reg_tb.sv` – Testbench

```
