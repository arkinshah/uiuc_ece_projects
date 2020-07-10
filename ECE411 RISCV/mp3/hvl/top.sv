module mp3_tb;
`timescale 1ns/10ps

/********************* Do not touch for proper compilation *******************/
// Instantiate Interfaces
tb_itf itf();
rvfi_itf rvfi(itf.clk, itf.rst);

// Instantiate Testbench
source_tb tb(
    .magic_mem_itf(itf),
    .mem_itf(itf),
    .sm_itf(itf),
    .tb_itf(itf),
    .rvfi(rvfi)
);
/****************************** End do not touch *****************************/

/************************ Signals necessary for monitor **********************/
// This section not required until CP3

assign rvfi.commit = ((dut.pipeline_core.memwb_to_wb.opcode != 7'd0) & (!dut.pipeline_core.stall)); // Set high when retiring an instruction
assign rvfi.halt = ((dut.pipeline_core.memwb_to_wb.opcode == 7'b1100011) & (dut.pipeline_core.memwb_to_wb.b_imm == 0));   // Set high when you detect an infinite loop
assign rvfi.inst = dut.pipeline_core.rvfi_memwb_to_wb.instruction;
assign rvfi.trap = 0;
assign rvfi.rs1_addr = dut.pipeline_core.rvfi_memwb_to_wb.rs1;
assign rvfi.rs2_addr = dut.pipeline_core.rvfi_memwb_to_wb.rs2;
assign rvfi.rs1_rdata = dut.pipeline_core.rvfi_memwb_to_wb.rs1_data;
assign rvfi.rs2_rdata = dut.pipeline_core.rvfi_memwb_to_wb.rs2_data;
assign rvfi.load_regfile = dut.pipeline_core.memwb_to_wb.load_regfile;
assign rvfi.rd_addr = dut.pipeline_core.rvfi_memwb_to_wb.rd;
assign rvfi.rd_wdata = (rvfi.rd_addr) ? dut.pipeline_core.rvfi_memwb_to_wb.rd_data : 0;
assign rvfi.pc_rdata = dut.pipeline_core.rvfi_memwb_to_wb.pc_curr;
assign rvfi.pc_wdata = dut.pipeline_core.rvfi_memwb_to_wb.pc_next;
assign rvfi.mem_addr = dut.pipeline_core.rvfi_memwb_to_wb.mem_addr;
assign rvfi.mem_rmask = dut.pipeline_core.rvfi_memwb_to_wb.rmask;
assign rvfi.mem_wmask = dut.pipeline_core.rvfi_memwb_to_wb.wmask;
assign rvfi.mem_rdata = dut.pipeline_core.rvfi_memwb_to_wb.mem_rdata;
assign rvfi.mem_wdata = dut.pipeline_core.rvfi_memwb_to_wb.mem_wdata;

initial rvfi.order = 0;
always @(posedge itf.clk iff rvfi.commit) rvfi.order <= rvfi.order + 1; // Modify for OoO
/**************************** End RVFIMON signals ****************************/

/********************* Assign Shadow Memory Signals Here *********************/
// This section not required until CP2
// Inst Shadow Memory Check
    assign itf.inst_resp = (dut.pipeline_core.inst_resp & (!dut.pipeline_core.stall));    //output logic 
    assign itf.inst_rdata = dut.pipeline_core.inst_rdata;  //output rv32i_word 
    assign itf.inst_read = dut.pipeline_core.inst_read;    //output logic 
    assign itf.inst_addr = dut.pipeline_core.inst_addr;    //output logic 
    // Data Shadow Memory Check
    assign itf.data_read = dut.pipeline_core.data_read;    //output logic 
    assign itf.data_write = dut.pipeline_core.data_write;  //output logic 
    assign itf.data_mbe = dut.pipeline_core.data_mbe;      //output logic [3:0] same as wmask
    assign itf.data_addr = dut.pipeline_core.data_addr;    //output logic [31:0] 
    assign itf.data_wdata = dut.pipeline_core.data_wdata;  //output logic [31:0] 
    assign itf.data_resp = (dut.pipeline_core.data_resp & (!dut.pipeline_core.stall));    //output logic 
    assign itf.data_rdata = dut.pipeline_core.data_rdata;  //output logic [31:0]
/*********************** End Shadow Memory Assignments ***********************/

// Set this to the proper value
assign itf.registers = dut.pipeline_core.s_writeback.regfile0.data;

/*********************** Instantiate your design here ************************/
logic clk;
assign clk = itf.clk;


mp3 dut(
    .clk(itf.clk),
    .rst(itf.rst),

    // Burst Memory Ports
    .mem_resp(itf.mem_resp),        //input logic 
    .mem_rdata(itf.mem_rdata),      //input logic [63:0] 
    .mem_read(itf.mem_read),        //output logic
    .mem_write(itf.mem_write),      //output logic
    .mem_addr(itf.mem_addr),        //output logic [31:0] 
    .mem_wdata(itf.mem_wdata)       //output logic [63:0] 
);
/***************************** End Instantiation *****************************/

endmodule
