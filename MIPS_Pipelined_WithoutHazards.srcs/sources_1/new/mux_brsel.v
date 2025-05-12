`timescale 1ns / 1ps

module mux_br_sel (
    input [31:0] pc_next_out2_out,
    input [31:0] branch_addr_out,
    input        Zero_out,
    input        Branch_out,
    input        Bne_out,
    output [31:0] pc_branch_out
);

    wire take_branch;
    assign take_branch = (Branch_out & Zero_out) | (Bne_out & ~Zero_out);
    assign pc_branch_out = take_branch ? branch_addr_out : pc_next_out2_out;

endmodule
