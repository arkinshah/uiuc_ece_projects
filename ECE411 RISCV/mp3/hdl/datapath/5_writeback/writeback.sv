`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

import rv32i_types::*;

module writeback
(
    input clk, rst, stall,
	 
	 input rv32i_control_word ctrl,
    input rv32i_word alu_out,
    input logic br_en,
    input rv32i_word mem_data,
	 input logic [4:0] rs1_DECODE,
	 input logic [4:0] rs2_DECODE,
	 
	 output rv32i_word regfilemux_out,
    output rv32i_word rs1_out,
    output rv32i_word rs2_out
);

/* Regfile */
regfile regfile0(
	.clk (clk),
	.rst (rst),
	.load (ctrl.load_regfile & ~stall),
	.src_a (rs1_DECODE),
	.src_b (rs2_DECODE),
	.dest (ctrl.rd),
	.in (regfilemux_out),
	.reg_a (rs1_out),
	.reg_b (rs2_out)
);


/* MUX */
always_comb begin : MUXES
    unique case (ctrl.regfilemux_sel)
         regfilemux::alu_out: regfilemux_out = alu_out;
		   regfilemux::br_en: regfilemux_out = br_en;
		   regfilemux::u_imm: regfilemux_out = ctrl.u_imm;
		   regfilemux::lw: regfilemux_out = mem_data;
			regfilemux::pc_plus4: regfilemux_out = ctrl.pc + 4;
		   regfilemux::lb:	begin
			unique case(alu_out[1:0])
				2'b00: begin
					if(mem_data[7] == 1'b0) begin
						regfilemux_out = {24'h000000, mem_data[7:0]};
					end
					else begin
						regfilemux_out = {24'hffffff, mem_data[7:0]};
					end
				end
				2'b01: begin
					if(mem_data[15] == 1'b0) begin
						regfilemux_out = {24'h000000, mem_data[15:8]};
					end
					else begin
						regfilemux_out = {24'hffffff, mem_data[15:8]};
					end					
				end
				2'b10: begin
					if(mem_data[23] == 1'b0) begin
						regfilemux_out = {24'h000000, mem_data[23:16]};
					end
					else begin
						regfilemux_out = {24'hffffff, mem_data[23:16]};
					end					
				end
				2'b11: begin
					if(mem_data[31] == 1'b0) begin
						regfilemux_out = {24'h000000, mem_data[31:24]};
					end
					else begin
						regfilemux_out = {24'hffffff, mem_data[31:24]};
					end					
				end
			endcase
		end
		regfilemux::lbu: begin
			unique case(alu_out[1:0])
				2'b00: regfilemux_out = {24'h000000, mem_data[7:0]};
				2'b01: regfilemux_out = {24'h000000, mem_data[15:8]};
				2'b10: regfilemux_out = {24'h000000, mem_data[23:16]};
				2'b11: regfilemux_out = {24'h000000, mem_data[31:24]};
			endcase
		end
		regfilemux::lh: begin
			unique case(alu_out[1])
				1'b0: begin
					if(mem_data[15] == 1'b0) begin
						regfilemux_out = {16'h0000, mem_data[15:0]};
					end
					else begin
						regfilemux_out = {16'hffff, mem_data[15:0]};
					end
				end
				1'b1: begin
					if(mem_data[31] == 1'b0) begin
						regfilemux_out = {16'h0000, mem_data[31:16]};
					end
					else begin
						regfilemux_out = {16'hffff, mem_data[31:16]};
					end					
				end
			endcase		  
		end
		regfilemux::lhu: begin
			unique case(alu_out[1])
				1'b0: regfilemux_out = {16'h0000, mem_data[15:0]};
				1'b1: regfilemux_out = {16'h0000, mem_data[31:16]};
			endcase
		end
      default: regfilemux_out = 32'b0; // `BAD_MUX_SEL;
    endcase
end

endmodule
