# MIPS Pipelined Processor – Hazard-Free- Harshdeep Singh

Welcome!  
This repository implements a classic **5-stage pipelined 32-bit MIPS Processor** in Verilog, arranged so that there are **no RAW hazards** in our test program. Supported instructions:

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
│   ├── datamem.v                 # Data memory with half-word support
│   ├── mem_wb_reg.v              # MEM/WB pipeline register
│   ├── mux_memtoreg.v            # MemtoReg mux
│   ├── mux_br_sel.v              # Branch PC mux
│   └── mux_jump_sel.v            # Jump PC mux
├── img/                          
│   ├── Screenshot%202025-05-07%20011235.png  
│   └── Screenshot%202025-05-07%20011352.png  
├── tb/                           
│   ├── pipelined_processor_tb.v  # Testbench and waveform logger
│   └── program1.mem              # 17 instruction hex words
└── README.md

## 🖼️ Pipelined Datapath

Blue = data paths | Orange = control signals  
Stages: IF → ID → EX → MEM → WB  
Pipeline registers: IF/ID, ID/EX, EX/MEM, MEM/WB

---

## 🎛️ Control Signals

### Single-Bit Signals

| Signal     | 0 (disabled)               | 1 (enabled)                                  |
|------------|----------------------------|-----------------------------------------------|
| **RegDst**   | write register = `rt`      | write register = `rd` (or `$ra` if `Jal=1`) |
| **Jump**     | no jump (`PC←PC+4`)        | jump (`PC←jump target`)                     |
| **Branch**   | `PC←PC+4`                  | `PC←branch target` if `Zero⊕Bne`             |
| **MemRead**  | no memory read             | read from data memory                       |
| **MemWrite** | no memory write            | write to data memory                        |
| **MemtoReg** | write-back = ALU result    | write-back = memory data                    |
| **ALUSrc**   | ALU B = register           | ALU B = immediate                           |
| **RegWrite** | no register write          | enable register write                       |
| **Jal**      | normal write-back          | write `PC+4` into `$ra`                     |
| **Bne**      | `beq` semantics            | `bne` semantics                             |
| **ExtSel**   | sign-extend immediate      | zero-extend immediate                       |

### Two-Bit Signals

| Signal     | `00`                             | `01`                | `10`                      | `11`         |
|------------|----------------------------------|---------------------|---------------------------|--------------|
| **ALUOp**    | ADD (PC+4, `lw`/`sw`/`jal`)     | SUB (`beq`/`bne`)   | R-type (use `funct`)      | SLTIU        |
| **mem_mode** | word access (`lw`/`sw`)         | half-word (`lhu`)    | —                         | —            |


## 📝 Module Descriptions

### `pipelined_processor.v`  
Instantiates the five pipeline stages, pipeline registers, control unit, and datapath.

### `pc.v`  
Program Counter: on posedge `clk`,  
```verilog
pc_out <= (reset ? 0 : pc_in);
adder.v
Computes pc_next = pc_out + 4.

instr_mem.v
256×32-bit word-addressed instruction memory:

verilog
Copy
Edit
instruction = memory[pc_out >> 2];
if_id_reg.v
IF/ID pipeline register. Latches the fetched instruction and pc+4 on posedge clk.

control_unit.v
Main decoder: maps 6-bit opcode → all control signals (RegDst, Jump, Branch, etc.).

reg_file.v
32×32 register file with:

Write on posedge clk:

verilog
Copy
Edit
if (RegWrite_final && write_reg_wb != 0)
    reg_array[write_reg_wb] <= write_data;
Read on negedge clk:

verilog
Copy
Edit
rd1_reg <= reg_array[rs];
rd2_reg <= reg_array[rt];
Outputs:

verilog
Copy
Edit
read_data1 = rd1_reg;
read_data2 = rd2_reg;
sign_ext.v
16-bit immediate → 32-bit via ExtSel.

shift_left_2.v
Branch offset shifter:

verilog
Copy
Edit
shift_left = imm_ext << 2;
shift_left_2_jump.v
Jump target shifter:

verilog
Copy
Edit
jump_shifted = instr_out[25:0] << 2;
id_ex_reg.v
ID/EX pipeline register for operands and control signals.

alu_control.v
Maps ALUOp + funct → 4-bit ALUControl.

mux_alu_src.v
ALU B-operand multiplexer (register vs immediate).

main_alu.v
ALU core:

AND, OR

ADD, SUB

SLT, SRL

SLTIU
Produces ALUResult and Zero flag.

alu_bj.v
Branch target address:

verilog
Copy
Edit
branch_addr = ex_pc + (imm_ext << 2);
regdst_mux.v
Selects write register (rt, rd, or $ra when Jal=1).

ex_mem_reg.v
EX/MEM pipeline register.

datamem.v
256×32 data memory:

Asynchronous read (MemRead)

Synchronous write (MemWrite)

Supports half-word loads (mem_mode).

mem_wb_reg.v
MEM/WB pipeline register.

mux_memtoreg.v
Write-back multiplexer: selects ALU result, memory data, or pc+4 (Jal case).

mux_br_sel.v
Branch multiplexer: selects between pc+4 and branch target (Zero⊕Bne).

mux_jump_sel.v
Final PC multiplexer: chooses branch output, jump target, or pc+4.



💾 Program & Testbench
tb/program1.mem
text
Copy
Edit
014B4820  // add   $t1, $t2, $t3
016C5022  // sub   $t2, $t3, $t4
01CD5824  // and   $t3, $t6, $t5
01F46825  // or    $t5, $t7, $a0
0235C82A  // slt   $t9, $s1, $s5
8D0C0000  // lw    $t4, 0($t0)
AD2E0004  // sw    $t6, 4($t1)
2D0D0005  // sltiu $t5, $t0, 5
950E0002  // lhu   $t6, 2($t0)
12560002  // beq   $s2, $s6, +2
1673FFFC  // bne   $s3, $s3, -4
08000010  // j     0x40
0C000011  // jal   0x44
01AA5820  // add   $t3, $t5, $t2
020C6822  // sub   $t5, $s0, $t4
01EF7025  // or    $t6, $t7, $t7
0307C824  // and   $t9, $t8, $t7
tb/pipelined_processor_tb.v
verilog
Copy
Edit
module pipelined_processor_tb;
  reg clk, reset;
  integer i;
  pipelined_processor uut(.clk(clk), .reset(reset));

  // Clock: 10 ns period
  always #5 clk = ~clk;

  initial begin
    clk = 0; reset = 1; #10 reset = 0;
    // Initialize registers
    uut.REGFILE.reg_array[8]  = 32'd5;  // $t0
    uut.REGFILE.reg_array[15] = 32'd7;  // $t7
    uut.REGFILE.reg_array[4]  = 32'd4;  // $a0
    // ...other inits...
    // Initialize data memory
    uut.MEM.memory[0] = 32'h0000ABCD;
    // Load instructions
    $readmemh("program1.mem", uut.IMEM.memory);

    $display("Cycle | PC    | Instr      | $t5 (R13)");
    for (i = 0; i < 40; i = i + 1) begin
      @(posedge clk);
      $display("%3d    | %h | %h | %h",
               i, uut.pc_out, uut.instruction, uut.REGFILE.reg_array[13]);
    end
    $finish;
  end
endmodule
<sub>This README gives a structured overview, explains each module, summarizes control signals in tables, and shows the sample program & testbench, mirroring the style of your multicycle reference.</sub>

