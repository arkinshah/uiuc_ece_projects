import rv32i_types::*;

module id_ex
(
    input clk, rst, stall,
	 
    input rv32i_control_word ctrl,
    input rv32i_word rs1_out_in,
    input rv32i_word rs2_out_in,

    output rv32i_word rs1_out_out,
    output rv32i_word rs2_out_out,
    output rv32i_control_word passed_ctrl
);

/* Registers */
ctrl_reg ctrl_register(
    .clk (clk),
    .rst (rst),
    .load (~stall),
    .in (ctrl),
    .out (passed_ctrl)
);

register rs1_reg(
	 .clk,
    .rst,
    .load(~stall),
    .in(rs1_out_in),
    .out(rs1_out_out)
);

register rs2_reg(
	 .clk,
    .rst,
    .load(~stall),
    .in(rs2_out_in),
    .out(rs2_out_out)
);

endmodule
