module decode (
    input  wire        clk,
    input  wire        rst,
    input  wire        wb_reg_write,
    input  wire [4:0]  wb_write_reg_location,
    input  wire [31:0] mem_wb_write_data,
    input  wire [31:0] if_id_instr,
    input  wire [31:0] if_id_npc,
    input  wire        id_ex_memread,
    input  wire [4:0]  id_ex_rt_for_haz,
    //outputs
    output wire        stall_pc,
    output wire        stall_ifid,
    output wire [1:0]  id_ex_wb,
    output wire [2:0]  id_ex_mem,
    output wire [3:0]  id_ex_execute,
    output wire [31:0] id_ex_npc,
    output wire [31:0] id_ex_readdat1,
    output wire [31:0] id_ex_readdat2,
    output wire [31:0] id_ex_sign_ext,
    output wire [4:0]  id_ex_instr_bits_20_16,
    output wire [4:0]  id_ex_instr_bits_15_11,
    output wire [4:0]  id_ex_instr_bits_25_21
);
    //internal wires
    wire [31:0] sign_ext_internal;
    wire [31:0] readdat1_internal;
    wire [31:0] readdat2_internal;
    wire [1:0]  wb_internal;
    wire [2:0]  mem_internal;
    wire [3:0]  ex_internal;
    wire        bubble_signal;

    hazard_detection hd0 (
        .id_ex_memread(id_ex_memread),
        .id_ex_rt     (id_ex_rt_for_haz),
        .if_id_rs     (if_id_instr[25:21]),
        .if_id_rt     (if_id_instr[20:16]),
        .stall_pc     (stall_pc),
        .stall_ifid   (stall_ifid),
        .bubble       (bubble_signal)
    );

    signExt sE0 (
        .immediate(if_id_instr[15:0]),
        .extended(sign_ext_internal)
    );

    regfile rf0 (
        .clk(clk),
        .rst(rst),
        .regwrite(wb_reg_write),
        .rs(if_id_instr[25:21]),
        .rt(if_id_instr[20:16]),
        .rd(wb_write_reg_location),
        .writedata(mem_wb_write_data),
        .A_readdat1(readdat1_internal),
        .B_readdat2(readdat2_internal)
    );

    control c0 (
        .clk(clk),
        .rst(rst),
        .opcode(if_id_instr[31:26]),
        .wb(wb_internal),
        .mem(mem_internal),
        .ex(ex_internal)
    );

    // wb=00, mem=000, ex=0000 the instruction commits nothing
    wire [1:0] wb_to_latch  = bubble_signal ? 2'b00   : wb_internal;
    wire [2:0] mem_to_latch = bubble_signal ? 3'b000  : mem_internal;
    wire [3:0] ex_to_latch  = bubble_signal ? 4'b0000 : ex_internal;

    idExLatch iEL0 (
        .clk(clk),
        .rst(rst),
        .ctl_wb(wb_to_latch),
        .ctl_mem(mem_to_latch),
        .ctl_ex(ex_to_latch),
        .npc(if_id_npc),
        .readdat1(readdat1_internal),
        .readdat2(readdat2_internal),
        .sign_ext(sign_ext_internal),
        .instr_bits_20_16(if_id_instr[20:16]),
        .instr_bits_15_11(if_id_instr[15:11]),
        .instr_bits_25_21(if_id_instr[25:21]),
        .wb_out(id_ex_wb),
        .mem_out(id_ex_mem),
        .ctl_out(id_ex_execute),
        .npc_out(id_ex_npc),
        .readdat1_out(id_ex_readdat1),
        .readdat2_out(id_ex_readdat2),
        .sign_ext_out(id_ex_sign_ext),
        .instr_bits_20_16_out(id_ex_instr_bits_20_16),
        .instr_bits_15_11_out(id_ex_instr_bits_15_11),
        .instr_bits_25_21_out(id_ex_instr_bits_25_21)
    );

endmodule