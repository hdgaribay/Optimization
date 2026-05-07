`timescale 1ns/1ps

module mips_pipeline_tb;
    reg clk;
    wire [31:0] R0 = uut.ID_stage.rf0.REG[0];
    wire [31:0] R1 = uut.ID_stage.rf0.REG[1];
    wire [31:0] R2 = uut.ID_stage.rf0.REG[2];
    wire [31:0] R3 = uut.ID_stage.rf0.REG[3];
    wire [31:0] R7 = uut.ID_stage.rf0.REG[7];
    wire [31:0] R8 = uut.ID_stage.rf0.REG[8];
    // DUT
    mips_pipeline_top uut (
        .clk(clk)
    );

    // 10 ns clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Waveform dump
    initial begin
        $dumpfile("mips_pipeline_tb.vcd");
        $dumpvars(0, mips_pipeline_tb);
    end

    integer cycle;
    initial cycle = 0;
    always @(posedge clk) cycle <= cycle + 1;

    always @(negedge clk) begin
        $display("---- Cycle %0d (t=%0t) ----", cycle, $time);

        // IF/ID
        $display("  IF/ID : pc_next=%h  instr=%h",
                 uut.IF_stage.next_pc,
                 uut.if_id_instr);

        // ID/EX latch outputs
        $display("  ID/EX : npc=%h  rd1=%h  rd2=%h  imm=%h  rt=%0d  rd=%0d  WB=%b MEM=%b EX=%b",
                 uut.id_ex_npc,
                 uut.id_ex_readdat1,
                 uut.id_ex_readdat2,
                 uut.id_ex_sign_ext,
                 uut.id_ex_instr_2016,
                 uut.id_ex_instr_1511,
                 uut.id_ex_wb,
                 uut.id_ex_mem,
                 uut.id_ex_execute);

        // EX/MEM latch outputs
        $display("  EX/MEM: alu=%h  rdat2=%h  wreg=%0d  zero=%b  br=%b mr=%b mw=%b  WB=%b",
                 uut.ex_mem_alu_result,
                 uut.ex_mem_rdata2,
                 uut.ex_mem_write_reg,
                 uut.ex_mem_zero,
                 uut.ex_mem_branch,
                 uut.ex_mem_memread,
                 uut.ex_mem_memwrite,
                 uut.ex_mem_wb);

        // MEM/WB write-back signals
        $display("  WB    : regwrite=%b  wdata=%h  wreg=%0d",
                 uut.wb_reg_write,
                 uut.wb_write_data,
                 uut.wb_write_reg);

        // Watch the registers
        $display("  REGS  : R0=%h  R1=%h  R2=%h  R3=%h",
                 uut.ID_stage.rf0.REG[0],
                 uut.ID_stage.rf0.REG[1],
                 uut.ID_stage.rf0.REG[2],
                 uut.ID_stage.rf0.REG[3]);
    end
    initial begin
        #350;
        $display("\n==== FINAL REGISTER STATE ====");
        $display("  R0 = %h (%0d)", uut.ID_stage.rf0.REG[0], uut.ID_stage.rf0.REG[0]);
        $display("  R1 = %h (%0d)", uut.ID_stage.rf0.REG[1], uut.ID_stage.rf0.REG[1]);
        $display("  R2 = %h (%0d)", uut.ID_stage.rf0.REG[2], uut.ID_stage.rf0.REG[2]);
        $display("  R3 = %h (%0d)", uut.ID_stage.rf0.REG[3], uut.ID_stage.rf0.REG[3]);
        $display("  Expected: R1 should evolve 1 -> 3 -> 6 -> 12 -> 12+R0_initial");
        $finish;
    end
endmodule