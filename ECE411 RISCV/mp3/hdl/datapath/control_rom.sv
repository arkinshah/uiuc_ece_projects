import rv32i_types::*;

module control_rom
(
	input rv32i_opcode opcode,
	input logic [2:0] funct3,
	input logic [6:0] funct7,
	input rv32i_word i_imm,
   input rv32i_word s_imm,
   input rv32i_word b_imm,
   input rv32i_word u_imm,
   input rv32i_word j_imm,
	input logic [4:0] rd,
	input logic [4:0] rs1,
   input logic [4:0] rs2,
	input rv32i_word pc,
	
	output rv32i_control_word ctrl
);

function void set_defaults();
	ctrl.opcode = opcode;
	ctrl.funct3 = funct3;
	ctrl.funct7 = funct7;
	ctrl.i_imm = i_imm;
	ctrl.s_imm = s_imm;
	ctrl.b_imm = b_imm;
	ctrl.u_imm = u_imm;
	ctrl.j_imm = j_imm;
	ctrl.rd = rd;
	ctrl.rs1 = rs1;
	ctrl.rs2 = rs2;
	ctrl.pc = pc;
	ctrl.load_regfile = 1'b0;
	ctrl.alumux1_sel = alumux::rs1_out;
	ctrl.alumux2_sel = alumux::i_imm;
	ctrl.regfilemux_sel = regfilemux::alu_out;
	ctrl.cmpmux_sel = cmpmux::rs2_out;
	ctrl.aluop = alu_ops'(funct3);
	ctrl.cmpop = branch_funct3_t'(funct3);
	ctrl.mem_read = 1'b0;
	ctrl.mem_write = 1'b0;
	ctrl.mem_byte_enable = 4'b1111;
	ctrl.allow_br = 1'b0;
	ctrl.allow_jmp = 1'b0;
endfunction

function void loadRegfile(regfilemux::regfilemux_sel_t sel);
	ctrl.regfilemux_sel = sel;
	ctrl.load_regfile = 1'b1;
endfunction

function void setALU(alumux::alumux1_sel_t sel1, alumux::alumux2_sel_t sel2, 
							logic setop = 1'b0, alu_ops op = alu_add);
	ctrl.alumux1_sel = sel1;
	ctrl.alumux2_sel = sel2;
	
	if(setop)
		ctrl.aluop = op;
endfunction

function void setCMP(cmpmux::cmpmux_sel_t sel, branch_funct3_t op);
	ctrl.cmpmux_sel = sel;
	ctrl.cmpop = op;
endfunction

always_comb begin
	/*** Default assignments ***/
	set_defaults();
	
	/*** Assign control signals based on opcode ***/
	case(opcode)
		op_lui: begin
			loadRegfile(regfilemux::u_imm);
		end
		
		op_auipc: begin
			setALU(alumux::pc_out, alumux::u_imm, 1'b1, alu_add);
			loadRegfile(regfilemux::alu_out);
		end
		
		op_jal: begin
			setALU(alumux::pc_out, alumux::j_imm, 1'b1, alu_add);
			loadRegfile(regfilemux::pc_plus4);
			ctrl.allow_jmp = 1'b1;
		end
		
		op_jalr: begin
			setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_add);
			loadRegfile(regfilemux::pc_plus4);
			ctrl.allow_jmp = 1'b1;
		end
		
		op_br: begin
			setALU(alumux::pc_out, alumux::b_imm, 1'b1, alu_add);
			ctrl.allow_br = 1'b1;
		end
		
		op_load: begin
			setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_add);
			ctrl.mem_read = 1'b1;
			case(funct3)
				3'b000: loadRegfile(regfilemux::lb);
				3'b001: loadRegfile(regfilemux::lh);
				3'b010: loadRegfile(regfilemux::lw);
				3'b100: loadRegfile(regfilemux::lbu);
				3'b101: loadRegfile(regfilemux::lhu);
				default: loadRegfile(regfilemux::lw);
			endcase
		end
		
		op_store: begin
			setALU(alumux::rs1_out, alumux::s_imm, 1'b1, alu_add);
			ctrl.mem_write = 1'b1;
		end
		
		op_imm: begin
			case(funct3)
				add, axor, aor, aand, sll: begin
					setALU(alumux::rs1_out, alumux::i_imm);
					loadRegfile(regfilemux::alu_out);
				end
				
				slt: begin
					setCMP(cmpmux::i_imm, blt);
					loadRegfile(regfilemux::br_en);
				end
				
				sltu: begin
					setCMP(cmpmux::i_imm, bltu);
					loadRegfile(regfilemux::br_en);
				end
				
				sr: begin
					if (funct7 == 7'b0100000) begin
						// Arithmetic shift
						setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_sra);
						loadRegfile(regfilemux::alu_out);
					end else begin
						// Logical shift
						setALU(alumux::rs1_out, alumux::i_imm);
						loadRegfile(regfilemux::alu_out);
					end
				end
			endcase
		end
		
		op_reg: begin
			case(funct3)	
				add: begin
					if (funct7 == 7'b0100000) begin
						// Subtraction
						setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_sub);
						loadRegfile(regfilemux::alu_out);
					end else begin
						// Addition
						setALU(alumux::rs1_out, alumux::rs2_out);
						loadRegfile(regfilemux::alu_out);
					end
				end
			
				axor, aor, aand, sll: begin
					setALU(alumux::rs1_out, alumux::rs2_out);
					loadRegfile(regfilemux::alu_out);
				end
				
				slt: begin
					setCMP(cmpmux::rs2_out, blt);
					loadRegfile(regfilemux::br_en);
				end
				
				sltu: begin
					setCMP(cmpmux::rs2_out, bltu);
					loadRegfile(regfilemux::br_en);
				end
				
				sr: begin
					if (funct7 == 7'b0100000) begin
						// Arithmetic shift
						setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_sra);
						loadRegfile(regfilemux::alu_out);
					end else begin
						// Logical shift
						setALU(alumux::rs1_out, alumux::rs2_out);
						loadRegfile(regfilemux::alu_out);
					end
				end
			endcase
		end
		default: ;
	endcase
end

endmodule
