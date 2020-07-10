import rv32i_types::*;

/*
Abstraction Key:
s_module instantiation = stage logic
r_module instantiation = stage register
signal_MODULE = signal from source MODULE
*/

module datapath(
    input logic clk,
    input logic rst,
    // I-CACHE
    input logic inst_resp,
    input rv32i_word inst_rdata,
    output logic inst_read,
    output rv32i_word inst_addr,
    // D-CACHE
    output logic data_read,
    output logic data_write,
    output logic [3:0] data_mbe, // same as wmask
    output logic [31:0] data_addr,
    output logic [31:0] data_wdata,
    input logic data_resp,
    input logic [31:0] data_rdata
);

/* Passed control words */
rv32i_control_word decode_to_idex;
rv32i_control_word idex_to_exmem;
rv32i_control_word exmem_to_memwb;
rv32i_control_word memwb_to_wb;

/* Module connecting signals */
rv32i_word pc_out_FETCH;
rv32i_word rom_instr_IFID;
rv32i_word pc_IFID;
rv32i_word rs1_out_IDEX;
rv32i_word rs2_out_IDEX;
rv32i_word alu_out_EXECUTE;
rv32i_word adder_out_EXECUTE;
logic br_en_EXECUTE;
rv32i_word rs1_out_EXECUTE;
rv32i_word rs2_out_EXECUTE;
rv32i_word alu_out_EXMEM;
rv32i_word adder_out_EXMEM;
logic br_en_EXMEM;
rv32i_word rs2_out_EXMEM;
rv32i_word rs2_out_MEMORY;
rv32i_word alu_out_MEMWB;
logic br_en_MEMWB;
rv32i_word mem_data_MEMWB;
rv32i_word regfilemux_out_WRITEBACK;
rv32i_word rs1_out_WRITEBACK;
rv32i_word rs2_out_WRITEBACK;

/* Misc signals */
pcmux::pcmux_sel_t pcmux_sel;
logic stall;
logic hazard;
logic squash;	// Used to squash instructions on branch mispredict

/* Assignments */
assign inst_addr = pc_out_FETCH;
assign pcmux_sel = pcmux::pcmux_sel_t'((br_en_EXMEM & exmem_to_memwb.allow_br) | exmem_to_memwb.allow_jmp);
assign stall = ((inst_read & (!inst_resp)) | ((data_read | data_write) & (!data_resp)));
assign squash = (((br_en_EXMEM & exmem_to_memwb.allow_br) | exmem_to_memwb.allow_jmp) & (!stall));

// Detect if stall is required due to hazard
hazard_detector hd
(
	.curr_opcode(decode_to_idex.opcode), 
	.prev_opcode(idex_to_exmem.opcode),
	.curr_rs1(decode_to_idex.rs1), 
	.curr_rs2(decode_to_idex.rs2), 
	.prev_rd(idex_to_exmem.rd),
	
	.hazard
);

fetch s_fetch
(
	.clk, .rst, .stall(stall | hazard),
	
	.pcmux_sel(pcmux_sel),					//input pcmux::pcmux_sel_t
	.alu_out((exmem_to_memwb.opcode != op_jalr) ? alu_out_EXMEM : {alu_out_EXMEM[31:1], 1'b0}),	//input rv32i_word 
	
	.inst_read,									//output logic 
	.pc_out(pc_out_FETCH)					//output rv32i_word 
);

if_id r_ifid
(
	.clk, .rst(rst | squash), .stall(stall | hazard),
	
	.pc_out(pc_out_FETCH),					//input rv32i_word 
	.inst_rdata,								//input rv32i_word 
	.inst_resp,									//input logic 
	
	.inst_addr(pc_IFID),						//output rv32i_word 
	.rom_instr(rom_instr_IFID)				//output rv32i_word 
);

decode s_decode
(
	.instr_addr(pc_IFID),					//input rv32i_word 
	.rom_instr(rom_instr_IFID),			//input rv32i_word
	
	.ctrl(decode_to_idex)					//output rv32i_control_word 
);

id_ex r_idex
(
	.clk, .rst(rst | squash | (hazard & (!stall))), .stall(stall),
	
	.ctrl(decode_to_idex),					//input rv32i_control_word 
	.rs1_out_in(rs1_out_WRITEBACK),		//input rv32i_word 
	.rs2_out_in(rs2_out_WRITEBACK),		//input rv32i_word
	
	.passed_ctrl(idex_to_exmem),			//output rv32i_control_word 
	.rs1_out_out(rs1_out_IDEX),			//output rv32i_word
	.rs2_out_out(rs2_out_IDEX)				//output rv32i_word
);

execute s_execute
(
	.ctrl(idex_to_exmem),					//input rv32i_control_word 
	.rs1_out(rs1_out_IDEX),					//input rv32i_word
	.rs2_out(rs2_out_IDEX),					//input rv32i_word
	.regfilemux_out_WRITEBACK,				//input rv32i_word
	.alu_out_EXMEM,							//input rv32i_word
	.rd_EXMEM(exmem_to_memwb.rd),			//input logic [4:0]
	.rd_MEMWB(memwb_to_wb.rd),				//input logic [4:0]
	.load_regfile_EXMEM(exmem_to_memwb.load_regfile),	//input logic
	.load_regfile_MEMWB(memwb_to_wb.load_regfile),		//input logic
	
	.alu_out(alu_out_EXECUTE),				//output rv32i_word 
	.adder_out(adder_out_EXECUTE),		//output rv32i_word 
	.br_en(br_en_EXECUTE),					//output logic 
	.exforwardmux1_out(rs1_out_EXECUTE),
	.exforwardmux2_out(rs2_out_EXECUTE)	//output rv32i_word
);

ex_mem r_exmem
(
	.clk, .rst(rst | squash), .stall(stall),
	
	.ctrl(idex_to_exmem),					//input rv32i_control_word 
	.alu_out_in(alu_out_EXECUTE),			//input rv32i_word 
	.adder_out_in(adder_out_EXECUTE),	//input rv32i_word 
	.br_en_in(br_en_EXECUTE),				//input logic 
	.rs2_out_in(rs2_out_EXECUTE),			//input rv32i_word
	
	.passed_ctrl(exmem_to_memwb),			//output rv32i_control_word 
	.alu_out_out(alu_out_EXMEM),			//output rv32i_word
	.adder_out_out(adder_out_EXMEM),		//output rv32i_word
	.br_en_out(br_en_EXMEM),				//output logic
	.rs2_out_out(rs2_out_EXMEM)			//output rv32i_word
);

memory s_memory
(
	.ctrl(exmem_to_memwb),					//input rv32i_control_word
	.alu_out(alu_out_EXMEM),				//input rv32i_word
	.adder_out(adder_out_EXMEM),			//input rv32i_word
	.rs2_out(rs2_out_EXMEM),				//input rv32i_word
	.regfilemux_out_WRITEBACK,				//input rv32i_word
	.rd_MEMWB(memwb_to_wb.rd),				//input logic [4:0]
	.load_regfile_MEMWB(memwb_to_wb.load_regfile),	//input logic
	
	.data_read,									//output logic
	.data_write,								//output logic
	.data_mbe,									//output logic [3:0]
	.data_addr,									//output logic [31:0]
	.data_wdata,								//output logic [31:0]
	.memforwardmux_out(rs2_out_MEMORY)
);      

mem_wb r_memwb
(
	.clk, .rst, .stall(stall),
	
	.ctrl(exmem_to_memwb),					//input rv32i_control_word 
	.alu_out_in(alu_out_EXMEM),			//input rv32i_word 
	.br_en_in(br_en_EXMEM),					//input rv32i_word 
	.mem_data_in(data_rdata),				//input rv32i_word
	
	.passed_ctrl(memwb_to_wb),				//output rv32i_control_word 
	.alu_out_out(alu_out_MEMWB),			//output rv32i_word 
	.br_en_out(br_en_MEMWB),				//output logic
	.mem_data_out(mem_data_MEMWB)			//output rv32i_word 
);

writeback s_writeback
(
	.clk, .rst, .stall(stall),
	
	.ctrl(memwb_to_wb),									//input rv32i_control_word 
	.alu_out(alu_out_MEMWB),							//input rv32i_word 
	.br_en(br_en_MEMWB),									//input logic 
	.mem_data(mem_data_MEMWB),							//input rv32i_word 
	.rs1_DECODE(decode_to_idex.rs1),					//input logic [4:0] 
	.rs2_DECODE(decode_to_idex.rs2),					//input logic [4:0] 
	
	.regfilemux_out(regfilemux_out_WRITEBACK),	//output rv32i_word
	.rs1_out(rs1_out_WRITEBACK),						//output rv32i_word 
	.rs2_out(rs2_out_WRITEBACK)						//output rv32i_word  
);

/* RVFI Monitor */
// synthesis translate_off
RVFIMonPacket rvfi_decode_to_idex;
RVFIMonPacket rvfi_idex_to_exmem;
RVFIMonPacket rvfi_exmem_to_memwb;
RVFIMonPacket rvfi_memwb_to_wb;

always_comb begin
	// Decode Signals
	rvfi_decode_to_idex.instruction = rom_instr_IFID;
	rvfi_decode_to_idex.pc_curr = pc_IFID;
	rvfi_decode_to_idex.pc_next = pc_IFID + 4;
	rvfi_decode_to_idex.rs1 = decode_to_idex.rs1;
	rvfi_decode_to_idex.rs2 = decode_to_idex.rs2;
	rvfi_decode_to_idex.rd = decode_to_idex.rd;
	
	// Execute Signals
	rvfi_idex_to_exmem.rs1_data = rs1_out_EXECUTE;
	
	// Memory Signals
	if(squash)
		rvfi_exmem_to_memwb.pc_next = (exmem_to_memwb.opcode != op_jalr) ? alu_out_EXMEM : {alu_out_EXMEM[31:1], 1'b0};
	
	rvfi_exmem_to_memwb.rs2_data = rs2_out_MEMORY;
	rvfi_exmem_to_memwb.mem_addr = data_addr;
	rvfi_exmem_to_memwb.rmask = exmem_to_memwb.mem_byte_enable;
	rvfi_exmem_to_memwb.wmask = data_mbe;
	rvfi_exmem_to_memwb.mem_rdata = data_rdata;
	rvfi_exmem_to_memwb.mem_wdata = data_wdata;
	
	// Writeback Signals
	rvfi_memwb_to_wb.rd_data = regfilemux_out_WRITEBACK;
end

rvfi_reg rvfi_reg_IDEX(
	.clk (clk),
	.rst (rst),
	.load (~stall),
	.in (rvfi_decode_to_idex),
	.out (rvfi_idex_to_exmem)
);

rvfi_reg rvfi_reg_EXMEM(
	.clk (clk),
	.rst (rst),
	.load (~stall),
	.in (rvfi_idex_to_exmem),
	.out (rvfi_exmem_to_memwb)
);

rvfi_reg rvfi_reg_MEMWB(
	.clk (clk),
	.rst (rst),
	.load (~stall),
	.in (rvfi_exmem_to_memwb),
	.out (rvfi_memwb_to_wb)
);
// synthesis translate_on

endmodule: datapath


// synthesis translate_off
module rvfi_reg
(
    input clk,
    input rst,
    input load,
    input RVFIMonPacket in,
    output RVFIMonPacket out
);

RVFIMonPacket data = 1'b0;

always_ff @(posedge clk)
begin
    if (rst)
    begin
        data <= '0;
    end
    else if (load)
    begin
        data <= in;
    end
    else
    begin
        data <= data;
    end
end

always_comb
begin
    out = data;
end

endmodule : rvfi_reg
// synthesis translate_on