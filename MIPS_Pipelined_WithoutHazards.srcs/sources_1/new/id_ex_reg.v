`timescale 1ns / 1ps

module id_ex_reg (
    input clk,
    input reset,
    input [31:0] pc_next_out,
    input [31:0] read_data1,
    input [31:0] read_data2,
    input [31:0] imm_ext,
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] rd,
    input [5:0] funct,
    input [27:0] jump_shifted,
    input RegDst,
    input Jump,
    input Branch,
    input MemRead,
    input MemtoReg,
    input [1:0] ALUOp,
    input MemWrite,
    input ALUSrc,
    input RegWrite,
    input Jal,
    input [1:0] mem_mode,
    input Bne,
    output reg [31:0] pc_next_out2,
    output reg [31:0] read_data1_out,
    output reg [31:0] read_data2_out,
    output reg [31:0] imm_ext_out,
    output reg [4:0] rs_out,
    output reg [4:0] rt_out,
    output reg [4:0] rd_out,
    output reg [5:0] funct_out,
    output reg [27:0] jump_shifted_out,
    output reg RegDst_EX,
    output reg Jump_out,
    output reg Branch_out,
    output reg MemRead_out,
    output reg MemtoReg_out,
    output reg [1:0] ALUOp_out,
    output reg MemWrite_out,
    output reg ALUSrc_out,
    output reg RegWrite_out,
    output reg Jal_out,
    output reg [1:0] mem_mode_out,
    output reg Bne_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_next_out2     <= 32'b0;
            read_data1_out   <= 32'b0;
            read_data2_out   <= 32'b0;
            imm_ext_out      <= 32'b0;
            rs_out           <= 5'b0;
            rt_out           <= 5'b0;
            rd_out           <= 5'b0;
            funct_out        <= 6'b0;
            jump_shifted_out <= 28'b0;
            RegDst_EX        <= 0;
            Jump_out         <= 0;
            Branch_out       <= 0;
            MemRead_out      <= 0;
            MemtoReg_out     <= 0;
            ALUOp_out        <= 2'b00;
            MemWrite_out     <= 0;
            ALUSrc_out       <= 0;
            RegWrite_out     <= 0;
            Jal_out          <= 0;
            mem_mode_out     <= 2'b00;
            Bne_out          <= 0;
        end else begin
            pc_next_out2     <= pc_next_out;
            read_data1_out   <= read_data1;
            read_data2_out   <= read_data2;
            imm_ext_out      <= imm_ext;
            rs_out           <= rs;
            rt_out           <= rt;
            rd_out           <= rd;
            funct_out        <= funct;
            jump_shifted_out <= jump_shifted;
            RegDst_EX        <= RegDst;
            Jump_out         <= Jump;
            Branch_out       <= Branch;
            MemRead_out      <= MemRead;
            MemtoReg_out     <= MemtoReg;
            ALUOp_out        <= ALUOp;
            MemWrite_out     <= MemWrite;
            ALUSrc_out       <= ALUSrc;
            RegWrite_out     <= RegWrite;
            Jal_out          <= Jal;
            mem_mode_out     <= mem_mode;
            Bne_out          <= Bne;
        end
    end

endmodule
