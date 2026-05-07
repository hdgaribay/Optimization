module EXECUTE(
input wire clk,
input wire [1:0] wb_ctl,  //11 inputs, based off of outputs of ID/EX latch (Lab 2-2)
input wire [2:0] m_ctl,
input wire regdst, alusrc,
input wire [1:0] aluop, 
input wire [31:0] npcout, rdata1, rdata2, s_extendout,
input wire [4:0] instrout_2016, instrout_1511,
input  wire [4:0]  id_ex_rs,
input  wire        ex_mem_regwrite_in,
input  wire [4:0]  ex_mem_write_reg_in,
input  wire        mem_wb_regwrite_in,
input  wire [4:0]  mem_wb_write_reg_in,
input  wire [31:0] mem_wb_write_data,    // for forward = 01
output wire [1:0] wb_ctlout, //9 total outputs from EX/MEM latch
output wire branch, memread, memwrite,
output wire [31:0] EX_MEM_NPC,
output wire zero,
output wire [31:0] alu_result, rdata2out,
output wire [4:0] five_bit_muxout
);
// signals
wire [31:0] adder_out, b, aluout;
wire [4:0] muxout;
wire [2:0] control;
wire aluzero;

// New for forwarding
wire [1:0]  forward_a, forward_b;
wire [31:0] alu_a_in;       // output of fwd_a mux to alu.a
wire [31:0] fwd_b_out;      // output of fwd_b mux to top_mux input
forwarding_unit fu0 (
    .ex_mem_regwrite (ex_mem_regwrite_in),
    .ex_mem_write_reg(ex_mem_write_reg_in),
    .mem_wb_regwrite (mem_wb_regwrite_in),
    .mem_wb_write_reg(mem_wb_write_reg_in),
    .id_ex_rs        (id_ex_rs),
    .id_ex_rt        (instrout_2016), 
    .forward_a       (forward_a),
    .forward_b       (forward_b)
);
// top input to alu
assign alu_a_in = (forward_a == 2'b10) ? alu_result        : // if forward asserts 10, forward alu result from ex
                  (forward_a == 2'b01) ? mem_wb_write_data :  // if forward asserts 01, forward alu result from data mem
                                         rdata1;
//bottom input to alu
assign fwd_b_out = (forward_b == 2'b10) ? alu_result        :
                   (forward_b == 2'b01) ? mem_wb_write_data :
                                          rdata2;
adder adder3(
.add_in1(npcout),
.add_in2(s_extendout),
.add_out(adder_out)
);
bottom_mux bottom_mux3(
.a(instrout_1511),  
.b(instrout_2016),
.sel(regdst),  
.y(muxout)
); 
alu_control alu_control3(
.funct(s_extendout[5:0]),
.aluop(aluop),
.select(control)
);
alu alu3(
.a(alu_a_in),
.b(b), // b <= output of top_mux
.control(control),
.result(aluout),
.zero(aluzero)
);
top_mux top_mux3(
.y(b), 
.a(s_extendout), 
.b(fwd_b_out), 
.alusrc(alusrc)
);
ex_mem ex_mem3(
.clk(clk),
.ctlwb_out(wb_ctl), // inputs, which should stem from intermediate modules 
.ctlm_out(m_ctl),
.adder_out(adder_out),
.aluzero(aluzero),
.aluout(aluout), 
.readdat2(rdata2),
.muxout(muxout), 
.wb_ctlout(wb_ctlout), // outputs going to FETCH or MEM/WB
.branch(branch), 
.memread(memread), 
.memwrite(memwrite), 
.add_result(EX_MEM_NPC),
.zero(zero),
.alu_result(alu_result), 
.rdata2out(rdata2out),
.five_bit_muxout(five_bit_muxout)
);
    
endmodule // IEXECUTE
