import rv32i_types::*;

module decode
(
	input rv32i_word instr_addr,
   input rv32i_word rom_instr,
	
	output rv32i_control_word ctrl
);

control_rom ROM(
	.opcode(rv32i_opcode'(rom_instr[6:0])),
	.funct3(rom_instr[14:12]), 
	.funct7(rom_instr[31:25]),
	.i_imm({{21{rom_instr[31]}}, rom_instr[30:20]}), 
	.s_imm({{21{rom_instr[31]}}, rom_instr[30:25], rom_instr[11:7]}), 
	.b_imm({{20{rom_instr[31]}}, rom_instr[7], rom_instr[30:25], rom_instr[11:8], 1'b0}), 
	.u_imm({rom_instr[31:12], 12'h000}), 
	.j_imm({{12{rom_instr[31]}}, rom_instr[19:12], rom_instr[20], rom_instr[30:21], 1'b0}),
	.rd(rom_instr[11:7]), 
	.rs1(rom_instr[19:15]), 
	.rs2(rom_instr[24:20]),
	.pc(instr_addr),
	.ctrl
);

endmodule
