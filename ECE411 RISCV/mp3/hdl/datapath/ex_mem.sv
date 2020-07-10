import rv32i_types::*;

module ex_mem
(
    input clk, rst, stall,
	 
	 input rv32i_control_word ctrl,
	 input rv32i_word alu_out_in,
	 input rv32i_word adder_out_in,
	 input logic br_en_in,
	 input rv32i_word rs2_out_in,
	 
	 output rv32i_control_word passed_ctrl,
	 output rv32i_word alu_out_out,
	 output rv32i_word adder_out_out,
	 output logic br_en_out,
	 output rv32i_word rs2_out_out
);

/* Registers */
register ALU_result(
    .clk  (clk),
    .rst (rst),
    .load (~stall),
    .in   (alu_out_in),
    .out  (alu_out_out)
);

register jump_address(
    .clk  (clk),
    .rst (rst),
    .load (~stall),
    .in   (adder_out_in),
    .out  (adder_out_out)
);

register #(1) branch(
    .clk  (clk),
    .rst (rst),
    .load (~stall),
    .in   (br_en_in),
    .out  (br_en_out)
);

ctrl_reg ctrl_register(
    .clk (clk),
    .rst (rst),
    .load (~stall),
    .in (ctrl),
    .out (passed_ctrl)
);

register rs2_reg(
	 .clk  (clk),
    .rst (rst),
    .load (~stall),
    .in   (rs2_out_in),
    .out  (rs2_out_out)
);

endmodule
