`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

import rv32i_types::*;

module fetch
(
    input clk, rst, stall,
	 
    input pcmux::pcmux_sel_t pcmux_sel,
	 input rv32i_word alu_out,
	 
    output logic inst_read,
    output rv32i_word pc_out

    /****** LOOK HERE. THIS ISN'T NECESSARY YET *****/
    //output logic [3:0] instr_byte_enable,
);

rv32i_word pcmux_out;

/* Output Assignments */
always_comb begin
	if(rst)
		inst_read = 1'b0;
	else
		inst_read = 1'b1;
end

/* PC Register */
pc_register PC(
	.clk (clk),
	.rst (rst),
	.load (~stall),
	.in (pcmux_out),
	.out (pc_out)
);

/* MUX */
always_comb begin : MUXES
    unique case (pcmux_sel)
        pcmux::pc_plus4: pcmux_out = pc_out + 4;
		  pcmux::alu_out: pcmux_out = alu_out;
        default: `BAD_MUX_SEL;
    endcase
end

endmodule