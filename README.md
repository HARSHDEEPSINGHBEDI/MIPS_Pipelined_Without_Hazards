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

MIPS_Pipelined_WithoutHazards/
├── src/
│ ├── pipelined_processor.v # Top-level 5-stage pipeline
│ ├── pc.v # Program Counter
│ ├── adder.v # PC+4 adder
│ ├── instr_mem.v # Instruction memory (256×32)
│ ├── if_id_reg.v # IF/ID pipeline register
│ ├── control_unit.v # Opcode → control signals
│ ├── reg_file.v # 32×32 register file (sync write, negedge read)
│ ├── sign_ext.v # Sign/zero-extender
│ ├── shift_left_2.v # Branch offset shifter
│ ├── shift_left_2_jump.v # Jump target shifter
│ ├── id_ex_reg.v # ID/EX pipeline register
│ ├── alu_control.v # ALUOp+funct → ALUControl
│ ├── mux_alu_src.v # ALU source B mux
│ ├── main_alu.v # ALU core
│ ├── alu_bj.v # Branch target adder
│ ├── regdst_mux.v # RegDst mux
│ ├── ex_mem_reg.v # EX/MEM pipeline register
│ ├── datamem.v # Data memory w/ half-word support
│ ├── mem_wb_reg.v # MEM/WB pipeline register
│ ├── mux_memtoreg.v # MemtoReg mux
│ ├── mux_br_sel.v # Branch PC mux
│ └── mux_jump_sel.v # Jump PC mux
├── img/
│ ├── Screenshot%202025-05-07%20011235.png
│ └── Screenshot%202025-05-07%20011352.png
├── tb/
│ ├── pipelined_processor_tb.v # Testbench & waveform logger
│ └── program1.mem # 17 instruction hex words
└── README.md


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
Instantiates the five pipeline stages, pipeline registers, control unit, and datapath.

### `pc.v`  
Program Counter: on posedge `clk`,  
```verilog
pc_out <= (reset ? 0 : pc_in);





