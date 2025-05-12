`timescale 1ns / 1ps

module main_alu (
    input [31:0] read_data1_out,
    input [31:0] alu_in_b,
    input [3:0]  ALUControl,
    output reg [31:0] ALUResult,
    output       Zero
);

    assign Zero = (ALUResult == 0);

    always @(*) begin
        case (ALUControl)
            4'b0000: ALUResult = read_data1_out & alu_in_b;
            4'b0001: ALUResult = read_data1_out | alu_in_b;
            4'b0010: ALUResult = read_data1_out + alu_in_b;
            4'b0011: ALUResult = alu_in_b >> read_data1_out[4:0];
            4'b0110: ALUResult = read_data1_out - alu_in_b;
            4'b0111: ALUResult = ($signed(read_data1_out) < $signed(alu_in_b)) ? 32'd1 : 32'd0;
            4'b1000: ALUResult = ($unsigned(read_data1_out) < $unsigned(alu_in_b)) ? 32'd1 : 32'd0;
            default: ALUResult = 32'hDEADBEEF;
        endcase
    end

endmodule
