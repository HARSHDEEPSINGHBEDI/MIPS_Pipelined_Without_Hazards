`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2025 12:49:38 PM
// Design Name: 
// Module Name: branch_target_adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module branch_target_adder (
    input [31:0] pc_next,          // PC + 4 (from IF/ID pipeline register)
    input [31:0] shift_left,       // Sign-extended immediate << 2
    output [31:0] branch_target    // Final branch address
);

    assign branch_target = pc_next + shift_left;

endmodule

