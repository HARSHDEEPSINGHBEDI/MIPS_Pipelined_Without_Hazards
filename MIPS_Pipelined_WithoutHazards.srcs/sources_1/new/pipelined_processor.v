`timescale 1ns / 1ps

module pipelined_processor (
    input clk,
    input reset
);

    // === IF Stage ===
    wire [31:0] pc_out, pc_next, pc_in, instruction;
    pc PC (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    adder PC_ADDER (
        .pc_out(pc_out),
        .pc_next(pc_next)
    );

    instr_mem IMEM (
        .pc_out(pc_out),
        .instruction(instruction)
    );

    wire [31:0] if_id_pc_next, if_id_instr;
    if_id_reg IF_ID (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .pc_next(pc_next),
        .instr_out(if_id_instr),
        .pc_next_out(if_id_pc_next)
    );

    // === ID Stage ===
    wire [5:0] opcode = if_id_instr[31:26];
    wire [4:0] rs_id = if_id_instr[25:21];
    wire [4:0] rt_id = if_id_instr[20:16];
    wire [4:0] rd_id = if_id_instr[15:11];
    wire [5:0] funct_id = if_id_instr[5:0];

    wire RegDst, Jump, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Jal, Bne, ExtSel;
    wire [1:0] ALUOp, mem_mode;
    control_unit CU (
        .opcode(opcode),
        .RegDst(RegDst),
        .Jump(Jump),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jal(Jal),
        .mem_mode(mem_mode),
        .Branch(Branch),
        .ExtSel(ExtSel),
        .Bne(Bne)
    );
    wire [4:0] rs = if_id_instr[25:21];
    wire [4:0] rt = if_id_instr[20:16];

    wire [31:0] reg_read_data1, reg_read_data2;
    wire [4:0] wb_reg_write;
    wire [31:0] write_data;
    wire RegWrite_WB;
    reg_file REGFILE (
        .clk(clk),
        .RegWrite_final(RegWrite_WB),
        //.rs(rs),
        //.rt(rt),   
        .instr_out(if_id_instr),
        .write_reg_wb(wb_reg_write),
        .write_data(write_data),
        .read_data1(reg_read_data1),
        .read_data2(reg_read_data2)
    );

    wire [31:0] imm_ext;
    sign_ext SIGN_EXT (
        .instr_out(if_id_instr),
        .ExtSel(ExtSel),
        .imm_ext(imm_ext)
    );

    wire [31:0] branch_offset;
    shift_left_2 SHIFT_BRANCH (
        .imm_ext_out2(imm_ext),
        .shift_left(branch_offset)
    );

    wire [27:0] jump_shifted;
    shift_left_2_jump SLJ (
        .instr_out(if_id_instr),
        .jump_shifted(jump_shifted)
    );

    // === ID/EX Pipeline Register ===
    wire [31:0] ex_pc, ex_rd1, ex_rd2, ex_imm;
    wire [4:0] ex_rs, ex_rt, ex_rd;
    wire [5:0] ex_funct;
    wire [27:0] ex_jump_shifted;
    wire RegDst_EX, Jump_EX, Branch_EX, MemRead_EX, MemtoReg_EX, MemWrite_EX;
    wire ALUSrc_EX, RegWrite_EX, Jal_EX, Bne_EX;
    wire [1:0] ALUOp_EX, mem_mode_EX;

    id_ex_reg ID_EX (
        .clk(clk),
        .reset(reset),
        .pc_next_out(if_id_pc_next),
        .read_data1(reg_read_data1),
        .read_data2(reg_read_data2),
        .imm_ext(imm_ext),
        .rs(rs_id),
        .rt(rt_id),
        .rd(rd_id),
        .funct(funct_id),
        .jump_shifted(jump_shifted),
        .RegDst(RegDst),
        .Jump(Jump),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jal(Jal),
        .mem_mode(mem_mode),
        .Bne(Bne),
        .pc_next_out2(ex_pc),
        .read_data1_out(ex_rd1),
        .read_data2_out(ex_rd2),
        .imm_ext_out(ex_imm),
        .rs_out(ex_rs),
        .rt_out(ex_rt),
        .rd_out(ex_rd),
        .funct_out(ex_funct),
        .jump_shifted_out(ex_jump_shifted),
        .RegDst_EX(RegDst_EX),
        .Jump_out(Jump_EX),
        .Branch_out(Branch_EX),
        .MemRead_out(MemRead_EX),
        .MemtoReg_out(MemtoReg_EX),
        .ALUOp_out(ALUOp_EX),
        .MemWrite_out(MemWrite_EX),
        .ALUSrc_out(ALUSrc_EX),
        .RegWrite_out(RegWrite_EX),
        .Jal_out(Jal_EX),
        .mem_mode_out(mem_mode_EX),
        .Bne_out(Bne_EX)
    );

    // === EX Stage ===
    wire [3:0] alu_ctrl;
    alu_control ALU_CTRL (
        .ALUOp(ALUOp_EX),
        .funct(ex_funct),
        .ALUControl(alu_ctrl)
    );

    wire [31:0] alu_in_b;
    mux_alu_src ALU_SRC_MUX (
        .read_data2_out(ex_rd2),
        .imm_ext_out(ex_imm),
        .ALUSrc_out(ALUSrc_EX),
        .alu_in_b(alu_in_b)
    );

    wire [31:0] alu_result;
    wire zero_flag;
    main_alu ALU (
        .read_data1_out(ex_rd1),
        .alu_in_b(alu_in_b),
        .ALUControl(alu_ctrl),
        .ALUResult(alu_result),
        .Zero(zero_flag)
    );

    wire [31:0] branch_target;
    alu_bj ALU_BRANCH (
        .pc_next_out2(ex_pc),
        .shift_left(branch_offset),
        .branch_addr(branch_target)
    );

    wire [4:0] write_reg_ex;
    regdst_mux REGDST_MUX (
        .rt_out(ex_rt),
        .rd_out(ex_rd),
        .RegDst_EX(RegDst_EX),
        .Jal_out(Jal_EX),
        .write_reg(write_reg_ex)
    );

    // === EX/MEM Pipeline Register ===
    wire [31:0] mem_alu_result, mem_branch_addr, mem_pc_next, mem_jump_target;
    wire mem_zero;
    wire [4:0] mem_reg_dst;
    wire Jump_MEM, Branch_MEM, MemRead_MEM, MemtoReg_MEM, MemWrite_MEM, ALUSrc_MEM, RegWrite_MEM, Jal_MEM, Bne_MEM;
    wire [1:0] mem_mode_MEM;

    ex_mem_reg EX_MEM (
        .clk(clk),
        .reset(reset),
        .ALUResult(alu_result),
        .Zero(zero_flag),
        .branch_addr(branch_target),
        .pc_next_out2(ex_pc),
        .jump_shifted_out(ex_jump_shifted),
        .write_reg(write_reg_ex),
        .Jump_out(Jump_EX),
        .Branch_out(Branch_EX),
        .MemRead_out(MemRead_EX),
        .MemtoReg_out(MemtoReg_EX),
        .ALUOp_out(ALUOp_EX),
        .MemWrite_out(MemWrite_EX),
        .ALUSrc_out(ALUSrc_EX),
        .RegWrite_out(RegWrite_EX),
        .Jal_out(Jal_EX),
        .mem_mode_out(mem_mode_EX),
        .Bne_out(Bne_EX),
        .ALUResult_out(mem_alu_result),
        .Zero_out(mem_zero),
        .branch_addr_out(mem_branch_addr),
        .jump_target_out(mem_jump_target),
        .pc_next_out2_out(mem_pc_next),
        .write_reg_dst_out(mem_reg_dst),
        .Jump_MEM(Jump_MEM),
        .Branch_MEM(Branch_MEM),
        .MemRead_MEM(MemRead_MEM),
        .MemtoReg_MEM(MemtoReg_MEM),
        .ALUOp_MEM(ALUOp_MEM),
        .MemWrite_MEM(MemWrite_MEM),
        .ALUSrc_MEM(ALUSrc_MEM),
        .RegWrite_MEM(RegWrite_MEM),
        .Jal_MEM(Jal_MEM),
        .mem_mode_MEM(mem_mode_MEM),
        .Bne_MEM(Bne_MEM)
    );

    // === MEM Stage ===
    wire [31:0] mem_data;
    datamem MEM (
        .clk(clk),
        .MemWrite_out(MemWrite_MEM),
        .MemRead_out(MemRead_MEM),
        .mem_mode_out(mem_mode_MEM),
        .ALUResult_out(mem_alu_result),
        .read_data2_out(ex_rd2),
        .read_data_mem(mem_data)
    );

    // === MEM/WB Pipeline Register ===
    wire [31:0] wb_mem_data, wb_alu_result;
    wire MemtoReg_WB, Jal_WB;
    mem_wb_reg MEM_WB (
        .clk(clk),
        .reset(reset),
        .read_data_mem(mem_data),
        .ALUResult_out(mem_alu_result),
        .write_reg_dst_out(mem_reg_dst),
        .RegWrite_MEM(RegWrite_MEM),
        .MemtoReg_MEM(MemtoReg_MEM),
        .Jal_MEM(Jal_MEM),
        .mem_data_out(wb_mem_data),
        .alu_result_out(wb_alu_result),
        .write_reg_wb(wb_reg_write),
        .RegWrite_final(RegWrite_WB),
        .MemtoReg_final(MemtoReg_WB),
        .Jal_WB(Jal_WB)
    );

    // === WB Mux ===
    mux_memtoreg WB_MUX (
        .alu_result_out(wb_alu_result),
        .mem_data(wb_mem_data),
        .pc_next(mem_pc_next),
        .MemtoReg_final(MemtoReg_WB),
        .Jal_WB(Jal_WB),
        .write_data(write_data)
    );

    // === Final PC selection ===
    wire [31:0] pc_branch_out;
    mux_br_sel BR_SEL (
        .pc_next_out2_out(mem_pc_next),
        .branch_addr_out(mem_branch_addr),
        .Zero_out(mem_zero),
        .Branch_out(Branch_MEM),
        .Bne_out(Bne_MEM),
        .pc_branch_out(pc_branch_out)
    );

    mux_jump_sel JMP_SEL (
        .pc_branch_out(pc_branch_out),
        .jump_target_out(mem_jump_target),
        .pc_next(pc_next),
        .Jump_out(Jump_MEM),
        .Branch_out(Branch_MEM),
        .pc_in(pc_in)
    );

endmodule
