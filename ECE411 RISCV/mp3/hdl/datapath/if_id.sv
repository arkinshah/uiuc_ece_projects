import rv32i_types::*;

module if_id
(
    input clk, rst, stall,
	 
    input rv32i_word pc_out,
    input rv32i_word inst_rdata,
    input logic inst_resp,
	 
    output rv32i_word inst_addr,
    output rv32i_word rom_instr 
);

/* Registers */
register addr(
    .clk  (clk),
    .rst (rst),
    .load (~stall),
    .in   (pc_out),
    .out  (inst_addr)
);

register instr(
    .clk  (clk),
    .rst (rst),
    .load (~stall),
    .in   (inst_rdata),
    .out  (rom_instr)
);

endmodule
