# Task 2 - Sequential Circuit Design

This folder contains **Task 2** of the **Xcelerium Training Program**, which focuses on the design and verification of **fundamental sequential and arithmetic digital circuits** using SystemVerilog.

 Each subfolder represents an independent design with its corresponding testbench for functional verification.

---

## Folder Structure
```
Task_2/
│
├── Adder_Tree_Multiplier/
│   ├── adder_tree_mult.sv
│   └── adder_tree_mult_tb_layered.sv
│
├── Array_Multiplier/
│   ├── adderrow.sv
│   ├── androw.sv
│   ├── mult_row.sv
│   ├── multiplier.sv
│   ├── multiplier_registered.sv
│   └── multiplier_registered_tb_layered.sv
│
├── Counter/
│   ├── counter.sv
│   └── counter_tb_layered.sv
│
├── Register/
│   ├── register32.sv
│   └── register32_tb_assert.sv
│
└── Shift_Register/
    ├── shift_reg.sv
    └── shift_reg_tb_layered.sv
```

---

## Module Description

### Adder Tree Multiplier
The adder tree multiplier implements an 8-bit by 8-bit multiplication using a structured partial-product and adder-tree approach. The inputs are first registered, after which partial products are generated and summed hierarchically using a multi-level adder tree. The final multiplication result is registered at the output, making this design suitable for synchronous digital systems.

**Files:**
- `adder_tree_mult.sv` – DUT
- `adder_tree_mult_tb_layered.sv` – Testbench

### Simulation Result:

#### Waveform:
<img width="906" height="89" alt="adder tree wave" src="https://github.com/user-attachments/assets/03ea7692-4d24-4dd8-afd4-212b9803a338" />

#### Simulation Log:
<img width="405" height="341" alt="adder tree log" src="https://github.com/user-attachments/assets/3dc2bb01-8534-4e2b-bd23-02d997d03990" />

---

### Array Multiplier
The array multiplier implements an 8-bit by 8-bit multiplication using a structured, row-by-row hardware architecture. Partial products are generated for each bit of the multiplier and accumulated through cascaded adder stages, forming a regular and scalable array structure. This design demonstrates how basic arithmetic blocks such as AND logic and adders can be combined to realize a complete multiplication unit, making it suitable for understanding hardware-based multiplication and data-path design.

### Structure
<img width="807" height="705" alt="array multiplier" src="https://github.com/user-attachments/assets/bad12f02-42bf-41a1-833f-d5606119c434" />

**Files:**
- `androw.sv` – Partial product generation block
- `adderrow.sv` – Adder row used for accumulation
- `mult_row.sv` – Combined AND and adder row
- `multiplier.sv` – Top-level DUT
- `multiplier_registered.sv` - Top-level DUT with registered inputs and outputs
- `multiplier_registered_tb_layered.sv` – Testbench

### Simulation Result:

#### Waveform:
<img width="904" height="119" alt="array mult wave" src="https://github.com/user-attachments/assets/ecc2157d-572d-44e7-91f5-dc514b81a32a" />

#### Simulation Log:
<img width="531" height="342" alt="array mult log" src="https://github.com/user-attachments/assets/98258458-d88d-4723-bab5-4115f82d64ba" />

---

### Up-Down Counter
The up-down counter module implements an 8-bit synchronous counter capable of counting either upward or downward based on a 
control signal. Counting is enabled through an explicit enable input, and the counter supports asynchronous reset. This module is commonly used in control logic, sequencing, and timing-related applications.

**Files:**
- `counter.sv` – DUT
- `counter_tb_layered.sv` – Testbench

### Simulation Result:

#### Waveform:
<img width="906" height="91" alt="counter wave" src="https://github.com/user-attachments/assets/c183c312-b7c6-416f-8307-bead7cfdf194" />

#### Simulation Log:
<img width="295" height="344" alt="counter png" src="https://github.com/user-attachments/assets/e14a705a-3c2d-4434-8897-838aace0d5b8" />

---

### 32-bit Register
The 32-bit register module stores a 32-bit data word and updates its contents synchronously based on a load control signal. 
It supports reset functionality and is intended for use in data-path designs where controlled data storage is required. This 
module represents a basic sequential storage element in digital systems.

**Files:**
- `register32.sv` – DUT
- `register32_tb_assert.sv` – Testbench

### Simulation Result:

#### Waveform:
<img width="905" height="89" alt="reg wave eda" src="https://github.com/user-attachments/assets/77e1d663-f603-4dcf-9aea-6575fc7e50b3" />

#### Simulation Log:
<img width="542" height="290" alt="reg 32 log" src="https://github.com/user-attachments/assets/fc48987a-f88c-4d6f-b138-d1ac371bf68e" />

---

### Shift Register
The shift register module provides serial data shifting functionality with a configurable width. Depending on the direction 
control signal, data can be shifted left or right when enabled. This module is useful for data serialization, bit manipulation, and intermediate storage in sequential digital designs.

**Files:**
- `shift_reg.sv` – DUT
- `shift_reg_tb_layered.sv` – Testbench

### Simulation Result:

#### Waveform:
<img width="905" height="106" alt="shift reg wave" src="https://github.com/user-attachments/assets/8955b628-d7d9-45e4-86f2-6c7b1177f0c9" />

#### Simulation Log:
<img width="325" height="341" alt="shift reg log" src="https://github.com/user-attachments/assets/d55ae2e6-8ba7-4f80-9043-b3374b065f1f" />

---
