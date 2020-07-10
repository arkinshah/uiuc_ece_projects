import rv32i_types::*;

module ex_forwarding_unit
(
	input logic [4:0] rs1_IDEX, rs2_IDEX, rd_EXMEM, rd_MEMWB,
	input logic load_regfile_EXMEM, load_regfile_MEMWB,
	
	output exforwardmux1::exforwardmux1_sel_t exforwardmux1_sel,
	output exforwardmux2::exforwardmux2_sel_t exforwardmux2_sel
);

always_comb begin
	if(load_regfile_EXMEM && (rd_EXMEM != 5'b0) && (rs1_IDEX == rd_EXMEM))
		exforwardmux1_sel = exforwardmux1::alu_out;
	else if(load_regfile_MEMWB && (rd_MEMWB != 5'b0) && (rs1_IDEX == rd_MEMWB))
		exforwardmux1_sel = exforwardmux1::regfilemux_out;
	else
		exforwardmux1_sel = exforwardmux1::rs1_out;
		
	if(load_regfile_EXMEM && (rd_EXMEM != 5'b0) && (rs2_IDEX == rd_EXMEM))
		exforwardmux2_sel = exforwardmux2::alu_out;
	else if(load_regfile_MEMWB && (rd_MEMWB != 5'b0) && (rs2_IDEX == rd_MEMWB))
		exforwardmux2_sel = exforwardmux2::regfilemux_out;
	else
		exforwardmux2_sel = exforwardmux2::rs2_out;
end

endmodule



module mem_forwarding_unit
(
	input logic [4:0] rs2_EXMEM, rd_MEMWB,
	input logic load_regfile_MEMWB,
	
	output memforwardmux::memforwardmux_sel_t memforwardmux_sel
);

always_comb begin
	if(load_regfile_MEMWB && (rd_MEMWB != 5'b0) && (rs2_EXMEM == rd_MEMWB))
		memforwardmux_sel = memforwardmux::regfilemux_out;
	else
		memforwardmux_sel = memforwardmux::rs2_out;
end

endmodule
