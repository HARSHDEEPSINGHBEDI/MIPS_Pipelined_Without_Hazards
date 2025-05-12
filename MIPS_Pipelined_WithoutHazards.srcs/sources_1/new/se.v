`timescale 1ns / 1ps

module sign_ext (
    input [31:0] instr_out,
    input ExtSel,
    output reg [31:0] imm_ext
);

    wire [15:0] imm;
    assign imm = instr_out[15:0];

    always @(*) begin
        case (ExtSel)
            1'b1: imm_ext = {{16{imm[15]}}, imm};
            1'b0: imm_ext = {16'b0, imm};
        endcase
    end

endmodule
