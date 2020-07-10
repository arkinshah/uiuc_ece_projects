import rv32i_types::*;

module mem_wb
(
    input clk, rst, stall,
	 
	 input rv32i_control_word ctrl,
    input rv32i_word alu_out_in,
    input logic br_en_in,
    input rv32i_word mem_data_in,
	 
    output rv32i_control_word passed_ctrl,
    output rv32i_word alu_out_out,
	 output logic br_en_out,
    output rv32i_word mem_data_out
);

/* Registers */
register alu_result(
    .clk  (clk),
    .rst (rst),
    .load (~stall),
    .in   (alu_out_in),
    .out  (alu_out_out)
);

register #(1) branch_result(
    .clk  (clk),
    .rst (rst),
    .load (~stall),
    .in   (br_en_in),
    .out  (br_en_out)
);

register mem_data_register(
    .clk  (clk),
    .rst (rst),
    .load (~stall),
    .in   (mem_data_in),
    .out  (mem_data_out)
);

ctrl_reg ctrl_register(
    .clk (clk),
    .rst (rst),
    .load (~stall),
    .in (ctrl),
    .out (passed_ctrl)
);

endmodule
