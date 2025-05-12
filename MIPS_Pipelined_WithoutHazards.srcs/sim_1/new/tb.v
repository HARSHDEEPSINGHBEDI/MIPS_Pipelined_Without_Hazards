`timescale 1ns / 1ps

module pipelined_processor_tb;

    reg clk;
    reg reset;
    integer i;

    pipelined_processor uut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        $display("\n==== Hazard-Free Pipelined MIPS Processor Simulation ====\n");

        clk = 0;
        reset = 1;
        #10 reset = 0;

        uut.REGFILE.reg_array[0]  = 32'd0;
        uut.REGFILE.reg_array[1]  = 32'd1;
        uut.REGFILE.reg_array[2]  = 32'd2;
        uut.REGFILE.reg_array[3]  = 32'd3;
        uut.REGFILE.reg_array[4]  = 32'd4;
        uut.REGFILE.reg_array[5]  = 32'd5;
        uut.REGFILE.reg_array[6]  = 32'd6;
        uut.REGFILE.reg_array[7]  = 32'd7;
        uut.REGFILE.reg_array[8]  = 32'd5;
        uut.REGFILE.reg_array[9]  = 32'd3;
        uut.REGFILE.reg_array[10] = 32'd5;
        uut.REGFILE.reg_array[11] = 32'd6;
        uut.REGFILE.reg_array[12] = 32'd7;
        uut.REGFILE.reg_array[13] = 32'd2;
        uut.REGFILE.reg_array[14] = 32'd1;
        uut.REGFILE.reg_array[16] = 32'd6;
        uut.REGFILE.reg_array[18] = 32'd8;
        uut.REGFILE.reg_array[19] = 32'd8;

        uut.MEM.memory[0] = 32'h0000ABCD;
        uut.MEM.memory[1] = 32'hDEADBEEF;
        uut.MEM.memory[2] = 32'hCAFEBABE;
        uut.MEM.memory[3] = 32'h12345678;
        uut.MEM.memory[4] = 32'h87654321;
        uut.MEM.memory[5] = 32'h0000000F;
        uut.MEM.memory[6] = 32'hFFFFFFFF;
        uut.MEM.memory[7] = 32'h00000ABC;
        uut.MEM.memory[8] = 32'h12312312;
        uut.MEM.memory[9] = 32'hDEDEDEDE;

        $readmemh("program1.mem", uut.IMEM.memory);

        $display("Instruction Memory Contents:");
        for (i = 0; i < 14; i = i + 1)
            $display("  IMEM[%0d] = 0x%h", i, uut.IMEM.memory[i]);

        for (i = 0; i < 40; i = i + 1) begin
            @(posedge clk);
            $display("\nT = %0t ns | PC = 0x%08h | Instruction = 0x%08h", 
                      $time, uut.pc_out, uut.instruction);

            $display("   $t0 = %-5d  $t1 = %-5d  $t2 = %-5d  $t3 = %-5d", 
                     uut.REGFILE.reg_array[8], uut.REGFILE.reg_array[9], 
                     uut.REGFILE.reg_array[10], uut.REGFILE.reg_array[11]);

            $display("   $t4 = %-5d  $t5 = %-5d  $t6 = %-5d  $ra = %-5d", 
                     uut.REGFILE.reg_array[12], uut.REGFILE.reg_array[13], 
                     uut.REGFILE.reg_array[14], uut.REGFILE.reg_array[31]);
        end

        $display("\n==== Final Data Memory State ====");
        for (i = 0; i < 10; i = i + 1)
            $display("   MEM[%0d] = 0x%08h", i, uut.MEM.memory[i]);

        $display("\n==== Simulation Complete ====\n");
        $finish;
    end

endmodule
