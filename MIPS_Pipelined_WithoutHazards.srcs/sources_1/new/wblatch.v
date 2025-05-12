`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/07/2025 01:24:09 AM
// Design Name: 
// Module Name: wblatch
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
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// Module Name: writeback_latch
// Description: Final stage latch to delay WB signals by 1 cycle for proper write
//////////////////////////////////////////////////////////////////////////////////

module writeback_latch (
    input clk,
    input reset,

    input [31:0] write_data_in,
    input [4:0]  write_reg_wb_in,
    input        RegWrite_in,

    output reg [31:0] write_data_out,
    output reg [4:0]  write_reg_wb_out,
    output reg        RegWrite_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            write_data_out   <= 32'b0;
            write_reg_wb_out <= 5'b0;
            RegWrite_out     <= 1'b0;
        end else begin
            write_data_out   <= write_data_in;
            write_reg_wb_out <= write_reg_wb_in;
            RegWrite_out     <= RegWrite_in;
        end
    end

endmodule
