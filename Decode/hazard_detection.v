module hazard_detection (
    input  wire        id_ex_memread,
    input  wire [4:0]  id_ex_rt,
    input  wire [4:0]  if_id_rs,
    input  wire [4:0]  if_id_rt,
    output wire        stall_pc,
    output wire        stall_ifid,
    output wire        bubble
);

    wire stall = id_ex_memread && (id_ex_rt != 5'd0) &&
                 ((id_ex_rt == if_id_rs) || (id_ex_rt == if_id_rt));

    assign stall_pc   = ~stall;   
    assign stall_ifid = ~stall;
    assign bubble     = stall;
endmodule