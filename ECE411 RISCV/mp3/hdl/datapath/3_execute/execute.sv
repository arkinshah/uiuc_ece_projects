`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

import rv32i_types::*;

module execute
(
	 input rv32i_control_word ctrl,
    input rv32i_word rs1_out,
    input rv32i_word rs2_out,
	 input rv32i_word regfilemux_out_WRITEBACK,
	 input rv32i_word alu_out_EXMEM,
	 input logic [4:0] rd_EXMEM, rd_MEMWB,
	 input logic load_regfile_EXMEM, load_regfile_MEMWB,
	 
    output rv32i_word alu_out,
    output rv32i_word adder_out,
    output logic br_en,
	 output rv32i_word exforwardmux1_out, exforwardmux2_out
);

/* Internal Variables */
rv32i_word alumux1_out;
rv32i_word alumux2_out;
rv32i_word cmpmux_out;
exforwardmux1::exforwardmux1_sel_t exforwardmux1_sel;
exforwardmux2::exforwardmux2_sel_t exforwardmux2_sel;

/* FORWARDING UNIT */
ex_forwarding_unit efu(
	.rs1_IDEX(ctrl.rs1), .rs2_IDEX(ctrl.rs2), 
	.rd_EXMEM, .rd_MEMWB,
	.load_regfile_EXMEM, .load_regfile_MEMWB,
	
	.exforwardmux1_sel,
	.exforwardmux2_sel
);

/* ALU & CMP & ADDER */
alu ALU(
	.aluop (ctrl.aluop),
	.f (alu_out),
	.a (alumux1_out),
	.b (alumux2_out)
);

cmp CMP(
	.cmpop (ctrl.cmpop),
	.f (br_en),
	.a (exforwardmux1_out),
	.b (cmpmux_out)
);

always_comb begin
	adder_out = alumux1_out + alumux2_out;
	adder_out[1:0] = 2'b00;
end

/* MUX */
always_comb begin : MUXES
	 unique case (exforwardmux1_sel)
		  exforwardmux1::rs1_out:			exforwardmux1_out = rs1_out;
		  exforwardmux1::regfilemux_out:	exforwardmux1_out = regfilemux_out_WRITEBACK;
		  exforwardmux1::alu_out:			exforwardmux1_out = alu_out_EXMEM;
	 endcase
	 unique case (exforwardmux2_sel)
		  exforwardmux2::rs2_out:			exforwardmux2_out = rs2_out;
		  exforwardmux2::regfilemux_out:	exforwardmux2_out = regfilemux_out_WRITEBACK;
		  exforwardmux2::alu_out:			exforwardmux2_out = alu_out_EXMEM;
	 endcase
    unique case (ctrl.cmpmux_sel)
        cmpmux::rs2_out: cmpmux_out = exforwardmux2_out;
		  cmpmux::i_imm: cmpmux_out = ctrl.i_imm;
        default: `BAD_MUX_SEL;
    endcase
    unique case (ctrl.alumux1_sel)
        alumux::rs1_out: alumux1_out = exforwardmux1_out;
		  alumux::pc_out: alumux1_out = ctrl.pc;
        default: `BAD_MUX_SEL;
    endcase
    unique case (ctrl.alumux2_sel)
        alumux::i_imm: alumux2_out = ctrl.i_imm;
		  alumux::u_imm: alumux2_out = ctrl.u_imm;
		  alumux::b_imm: alumux2_out = ctrl.b_imm;
		  alumux::s_imm: alumux2_out = ctrl.s_imm;
		  alumux::j_imm: alumux2_out = ctrl.j_imm;
		  alumux::rs2_out: alumux2_out = exforwardmux2_out;
        default: `BAD_MUX_SEL;
    endcase
end

endmodule: execute