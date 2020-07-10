`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

import rv32i_types::*;

module memory
(
    input rv32i_control_word ctrl,
	 input rv32i_word alu_out,
	 input rv32i_word adder_out,
	 input rv32i_word rs2_out,
	 input rv32i_word regfilemux_out_WRITEBACK,
	 input logic [4:0] rd_MEMWB,
	 input logic load_regfile_MEMWB,
	 
	 output logic data_read,
	 output logic data_write,
	 output logic [3:0] data_mbe,
	 output logic [31:0] data_addr,
	 output logic [31:0] data_wdata,
	 output rv32i_word memforwardmux_out
);

/* INTERNAL VARIABLES */
memforwardmux::memforwardmux_sel_t memforwardmux_sel;
rv32i_word shifted_wdata;

/* FORWARDING UNIT */
mem_forwarding_unit mfu
(
	.rs2_EXMEM(ctrl.rs2), 
	.rd_MEMWB,
	.load_regfile_MEMWB,
	
	.memforwardmux_sel
);

/* MUX */
always_comb begin
	unique case (memforwardmux_sel)
		memforwardmux::rs2_out:				memforwardmux_out = rs2_out;
		memforwardmux::regfilemux_out:	memforwardmux_out = regfilemux_out_WRITEBACK;
	endcase
end

always_comb begin
	data_mbe = 4'b000;
	shifted_wdata = memforwardmux_out;
	
	if(ctrl.opcode == op_store) begin
		case(ctrl.funct3)
			3'b000: begin										/* SB */
				case(alu_out[1:0])
					2'b00: data_mbe = 4'b0001;
					2'b01: data_mbe = 4'b0010;
					2'b10: data_mbe = 4'b0100;
					2'b11: data_mbe = 4'b1000;
				endcase
			end
			3'b001: begin										/* SH */
				case(alu_out[1:0])
					2'b00: data_mbe = 4'b0011;
					2'b10: data_mbe = 4'b1100;
				endcase
			end
			3'b010: data_mbe = 4'b1111;							/* SW */
			default: data_mbe = 4'b0000;
		endcase
		
		shifted_wdata = memforwardmux_out << (alu_out[1:0] * 8);
	end
end

/* MEMORY ASSIGNMENTS */
assign data_read = ctrl.mem_read;
assign data_write = ctrl.mem_write;
assign data_addr = (data_read | data_write) ? adder_out : 0;
assign data_wdata = shifted_wdata;

endmodule
