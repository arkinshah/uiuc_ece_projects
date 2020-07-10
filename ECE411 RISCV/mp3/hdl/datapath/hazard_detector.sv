import rv32i_types::*;

module hazard_detector
(
	input rv32i_opcode curr_opcode, prev_opcode,
	input logic [4:0] curr_rs1, curr_rs2, prev_rd,
	
	output logic hazard
);

always_comb begin
	hazard = 1'b0;

	if(prev_opcode == op_load) begin
		case(curr_opcode)
			op_br, op_reg:	begin							// Uses rs1 and rs2 source registers
				if(curr_rs1 == prev_rd || curr_rs2 == prev_rd)
					hazard = 1'b1;
			end
			op_jalr, op_store, op_imm:	begin			// Uses rs1 source register
				if(curr_rs1 == prev_rd)
					hazard = 1'b1;
			end
			default: ;										// Uses no source registers
		endcase
	end
end

endmodule
