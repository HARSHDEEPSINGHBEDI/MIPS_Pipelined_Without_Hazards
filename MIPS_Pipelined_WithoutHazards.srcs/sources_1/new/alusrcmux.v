`timescale 1ns / 1ps

module mux_alu_src (
    input [31:0] read_data2_out,
    input [31:0] imm_ext_out,
    input        ALUSrc_out,
    output reg [31:0] alu_in_b
);

    always @(*) begin
        if (ALUSrc_out)
            alu_in_b = imm_ext_out;
        else
            alu_in_b = read_data2_out;
    end

endmodule
