# MIPS Pipelined Processor – Hazard-Free - Harshdeep Singh


This repository implements a classic **5-stage pipelined 32-bit MIPS Processor** in Verilog, arranged so that there are **no RAW hazards** in our test program.

Supported instructions:
1. `add`  
2. `sub`  
3. `and`  
4. `or`  
5. `lw`  
6. `sw`  
7. `slt`  
8. `sltiu`  
9. `srl`  
10. `lhu`  
11. `beq`  
12. `bne`  
13. `j`  
14. `jal`  
15. (repeat) `add`  
16. (repeat) `sub`  
17. (repeat) `and`  

---

## 📁 Repository Layout

```text
MIPS_Pipelined_WithoutHazards/
├── src/
│   ├── pipelined_processor.v     # Top-level 5-stage pipeline
│   ├── pc.v                      # Program Counter
│   ├── adder.v                   # PC+4 adder
│   ├── instr_mem.v               # Instruction memory (256×32)
│   ├── if_id_reg.v               # IF/ID pipeline register
│   ├── control_unit.v            # Opcode → control signals
│   ├── reg_file.v                # 32×32 register file (sync write, negedge read)
│   ├── sign_ext.v                # Sign/zero-extender
│   ├── shift_left_2.v            # Branch offset shifter
│   ├── shift_left_2_jump.v       # Jump target shifter
│   ├── id_ex_reg.v               # ID/EX pipeline register
│   ├── alu_control.v             # ALUOp+funct → ALUControl
│   ├── mux_alu_src.v             # ALU source B mux
│   ├── main_alu.v                # ALU core
│   ├── alu_bj.v                  # Branch target adder
│   ├── regdst_mux.v              # RegDst mux
│   ├── ex_mem_reg.v              # EX/MEM pipeline register
│   ├── datamem.v                 # Data memory w/ half-word support
│   ├── mem_wb_reg.v              # MEM/WB pipeline register
│   ├── mux_memtoreg.v            # MemtoReg mux
│   ├── mux_br_sel.v              # Branch PC mux
│   └── mux_jump_sel.v            # Jump PC mux
├── img/
│   ├── Screenshot%202025-05-07%20011235.png
│   └── Screenshot%202025-05-07%20011352.png
├── tb/
│   ├── pipelined_processor_tb.v  # Testbench & waveform logger
│   └── program1.mem              # 17 instruction hex words
└── README.md
```

---

## 🖼️ Pipelined Datapath

Blue = data paths | Orange = control signals  
Stages: IF → ID → EX → MEM → WB  
Pipeline registers: IF/ID, ID/EX, EX/MEM, MEM/WB

![Datapath Stage View 1](img/Screenshot%202025-05-07%20011235.png)  

![Datapath Stage View 2](img/Screenshot%202025-05-07%20011352.png)  

---

## 🎛️ Control Signals

### Single-Bit Signals

| Signal      | 0 (disabled)                           | 1 (enabled)                                      |
|-------------|----------------------------------------|--------------------------------------------------|
| **RegDst**  | write register = `rt`                  | write register = `rd` (or `$ra` if `Jal=1`)      |
| **Jump**    | no jump (`PC←PC+4`)                    | jump (`PC←jump target`)                          |
| **Branch**  | `PC←PC+4`                              | `PC←branch target` if `Zero⊕Bne`                  |
| **MemRead** | no memory read                         | read from data memory                            |
| **MemWrite**| no memory write                        | write to data memory                             |
| **MemtoReg**| write-back = ALU result                | write-back = memory data                         |
| **ALUSrc**  | ALU B = register                       | ALU B = immediate                                |
| **RegWrite**| no register write                      | enable register write                            |
| **Jal**     | normal write-back                      | write `PC+4` into `$ra`                          |
| **Bne**     | `beq` semantics                        | `bne` semantics                                  |
| **ExtSel**  | sign-extend immediate                  | zero-extend immediate                            |

### Two-Bit Signals

| Signal      | `00`                             | `01`                    | `10`                      | `11`         |
|-------------|----------------------------------|-------------------------|---------------------------|--------------|
| **ALUOp**   | ADD (PC+4, `lw`/`sw`/`jal`)     | SUB (`beq`/`bne`)       | R-type (use `funct`)      | SLTIU        |
| **mem_mode**| word access (`lw`/`sw`)         | half-word (`lhu`)       | —                         | —            |

---

## 📝 Module Descriptions

### `pipelined_processor.v`  
Top‐level wrapper that ties together all five stages (IF, ID, EX, MEM, WB), their pipeline registers, and the control unit to form the complete pipelined datapath.

### `pc.v`  
Holds the program counter. On each rising clock edge, either resets to `0` or loads the next PC value (`pc_in`).

### `adder.v`  
Simple combinational adder that computes `pc_next = pc_out + 4` for sequential instruction fetch.

### `instr_mem.v`  
256×32-bit read-only instruction memory. Uses the high bits of `pc_out` (word address) to fetch the current instruction.

### `if_id_reg.v`  
IF/ID pipeline register. Captures the fetched instruction and `pc+4` on the rising edge of the clock for use in the ID stage.

### `control_unit.v`  
Main opcode decoder. Translates the 6-bit opcode into all necessary control signals (`RegDst`, `ALUSrc`, `MemRead`, etc.) for each instruction type.

### `reg_file.v`  
32×32 register file with two read ports and one write port.  
- Writes on the positive clock edge when `RegWrite_final` is asserted.  
- Reads the operands synchronously on the negative edge to avoid races.

### `sign_ext.v`  
Extracts the 16-bit immediate field from the instruction and either sign-extends or zero-extends it to 32 bits under `ExtSel` control.

### `shift_left_2.v`  
Left-shifts the extended immediate by 2 bits to form the branch offset used in address calculation.

### `shift_left_2_jump.v`  
Left-shifts the 26-bit jump target field by 2 to produce the high 28 bits of the jump address.

### `id_ex_reg.v`  
ID/EX pipeline register. Latches decoded register operands, the extended immediate, and all ID-stage control signals on the rising clock edge.

### `alu_control.v`  
Combines the 2-bit `ALUOp` from the control unit with the 6-bit R-type `funct` field to generate a 4-bit ALU control code.

### `mux_alu_src.v`  
Selects the ALU’s second operand between the second register operand (for R-types) or the immediate (for I-types like `lw`, `sw`, `sltiu`).

### `main_alu.v`  
Performs the actual arithmetic or logic operation specified by the ALU control code. Outputs the 32-bit result and a Zero flag for branch tests.

### `alu_bj.v`  
Adds the shifted branch offset to the incremented PC (`pc+4`) to compute the branch target address.

### `regdst_mux.v`  
Chooses which register number to use for write-back:  
- `rt` for I-type instructions  
- `rd` for R-type  
- `$ra` (31) when performing `jal`

### `ex_mem_reg.v`  
EX/MEM pipeline register. Captures ALU outputs, branch target, jump target bits, destination register, and EX-stage control signals.

### `datamem.v`  
256×32-bit data memory.  
- Asynchronously produces read data when `MemRead` is high.  
- Synchronously writes data at the rising clock when `MemWrite` is asserted.  
- Supports half-word loads (`lhu`) via `mem_mode`.

### `mem_wb_reg.v`  
MEM/WB pipeline register. Latches memory read data, ALU result, destination register ID, and MEM-stage control signals on the rising clock.

### `mux_memtoreg.v`  
Selects the data to write back into the register file from among: the ALU result, the data memory output, or the incremented PC (for `jal`).

### `mux_br_sel.v`  
Branch decision mux: chooses between the sequential PC+4 and the branch target based on `Branch` & Zero⊕Bne.

### `mux_jump_sel.v`  
Final PC multiplexer: selects the next `pc_in` from the branch mux output, the jump target, or sequential PC+4 under `Jump` control.







