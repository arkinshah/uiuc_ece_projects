import rv32i_types::*;

module mp3(
    input logic clk,
    input logic rst,

    // Burst Memory Ports
    input logic mem_resp, 
    input logic [63:0] mem_rdata,
    output logic mem_read, 
    output logic mem_write, 
    output logic [31:0] mem_addr,
    output logic [63:0] mem_wdata
);  

    // CAD & Burst Memory Connections
    logic mem_resp_top, mem_read_top, mem_write_top, load_cache;
    logic [63:0] mem_rdata_top, mem_wdata_top;
    logic [31:0] mem_addr_top;

    logic [255:0] cache_reg_in;
    
    assign mem_read = mem_read_top;
    assign mem_write = mem_write_top;
    assign mem_addr = mem_addr_top;
    assign mem_wdata = mem_wdata_top;
    assign mem_rdata_top = mem_rdata;
    assign mem_resp_top = mem_resp;

    // I-CACHE & Core Connections
    logic inst_resp_w, inst_read_w;
    logic [31:0] inst_addr_w, inst_rdata_w;

    // D-CACHE & Core Connections
    logic data_read_w, data_write_w, data_resp_w; 
    logic [3:0] data_mbe_w;
    logic [31:0] data_addr_w, data_wdata_w, data_rdata_w;

    // I-CACHE & Arbiter Connections
    logic i_read_w, i_write_w, arb_iresp_w; 
    logic [31:0] icache_address_w;
    logic [255:0] icache_wdata_w, arb_irdata_w; 
    logic [31:0] icache_mbe_w;

    // D-CACHE & Arbiter Connections
    logic d_read_w, d_write_w, arb_dresp_w; 
    logic [31:0] dcache_address_w;
    logic [255:0] dcache_wdata_w, arb_drdata_w;
    logic [31:0] dcache_mbe_w;

    // L2 & Arbiter Connections
    logic [255:0] l2_rdata_w, arb_wdata_w;
	logic [31:0] arb_pmem_addr_w, arb_mbe_w;
    logic l2_resp_w, arb_mem_read_w, arb_mem_write_w; 
    logic l2_hit_w;

    // L2 Cache & CAD Connections
    logic pmem_resp_w, pmem_read_w, pmem_write_w;
    logic [255:0] pmem_rdata_w, pmem_wdata_w;
    logic [31:0] pmem_address_w;

datapath pipeline_core(
    .clk,
    .rst,
    // I-CACHE
    .inst_resp(inst_resp_w),    //input logic 
    .inst_rdata(inst_rdata_w),  //input rv32i_word 
    .inst_read(inst_read_w),    //output logic 
    .inst_addr(inst_addr_w),    //output rv32i_word 
    // D-CACHE
    .data_read(data_read_w),    //output logic 
    .data_write(data_write_w),  //output logic 
    .data_mbe(data_mbe_w),      //output logic [3:0] same as wmask
    .data_addr(data_addr_w),    //output logic [31:0] 
    .data_wdata(data_wdata_w),  //output logic [31:0] 
    .data_resp(data_resp_w),    //input logic 
    .data_rdata(data_rdata_w)   //input logic [31:0] 
);

cache icache(
    .clk,
    .rst,

    /****  CACHE CONTROL  *****/

    // from cacheline adaptor (from PMEM)
    .pmem_resp(arb_iresp_w),                        //input logic 

    // to cacheline adaptor (to PMEM)
    .pmem_read(i_read_w),                           //output logic 
    .pmem_write(i_write_w),                         //output logic 

    // from CPU
    .mem_read(inst_read_w),                         //input logic 
    .mem_write(1'b0),                               //input logic 

    // to CPU
    .mem_resp(inst_resp_w),                         //output logic 

    /**** CACHE DATAPATH ****/

    // From CPU
    .mem_address(inst_addr_w),                      //input rv32i_word 

    // From PMEM or technically Cacheline Adaptor
    .pmem_rdata(arb_irdata_w),                      // input logic [255:0] 

    // to PMEM or technically Cacheline Adaptor
    .pmem_address(icache_address_w),                //output rv32i_word 
    .pmem_wdata(icache_wdata_w),                    //output logic [255:0] 
    .pmem_mbe(icache_mbe_w),                        //output logic [31:0] 

    /****  BUS ADAPTOR  *****/

    // from CPU
    .mem_wdata(32'd0),                              //input rv32i_word 
    .mem_rdata(inst_rdata_w),                       //output rv32i_word  
    .mem_byte_enable(4'd0)                          //input logic [3:0]
);

cache dcache(
    .clk,
    .rst,

    /****  CACHE CONTROL  *****/

    // from cacheline adaptor (from PMEM)
    .pmem_resp(arb_dresp_w),                            //input logic 

    // to cacheline adaptor (to PMEM)
    .pmem_read(d_read_w),                               //output logic 
    .pmem_write(d_write_w),                             //output logic 

    // from CPU
    .mem_read(data_read_w),                             //input logic 
    .mem_write(data_write_w),                           //input logic 

    // to CPU
    .mem_resp(data_resp_w),                             //output logic 

    /**** CACHE DATAPATH ****/

    // From CPU
    .mem_address(data_addr_w),                          //input rv32i_word 

    // From PMEM or technically Cacheline Adaptor
    .pmem_rdata(arb_drdata_w),                          // input logic [255:0] 

    // to PMEM or technically Cacheline Adaptor
    .pmem_address(dcache_address_w),                    //output rv32i_word 
    .pmem_wdata(dcache_wdata_w),                        //output logic [255:0] 
    .pmem_mbe(dcache_mbe_w),                            //output logic [31:0]

    /****  BUS ADAPTOR  *****/

    // from CPU
    .mem_wdata(data_wdata_w),                           //input rv32i_word 
    .mem_rdata(data_rdata_w),                           //output rv32i_word  
    .mem_byte_enable(data_mbe_w)                        //input logic [3:0]
);

arbiter cache_arbiter(
    .clk,
    .rst,

    // From Caches to Arbiter
    .i_read(i_read_w),                  //input logic 
    .i_write(i_write_w),                //input logic 
    .d_read(d_read_w),                  //input logic 
    .d_write(d_write_w),                //input logic 

    .icache_address(icache_address_w),  //input rv32i_word 
    .icache_wdata(icache_wdata_w),      //input logic [255:0]
    .icache_mbe(icache_mbe_w),          //input logic [31:0] 

    .dcache_address(dcache_address_w),  //input rv32i_word 
    .dcache_wdata(dcache_wdata_w),      //input logic [255:0]
    .dcache_mbe(dcache_mbe_w),          //input logic [31:0] 

    // Outputs to Caches Above
	.arb_irdata(arb_irdata_w),          //output logic [255:0] 
    .arb_iresp(arb_iresp_w),            //output logic 
	.arb_drdata(arb_drdata_w),          //output logic [255:0] 
	.arb_dresp(arb_dresp_w),            //output logic 

    // From L2 (Cacheline Adaptor) to Arbiter
    .l2_rdata(l2_rdata_w),              //input [255:0] 
    .l2_resp(l2_resp_w),                //input logic 
    //.l2_hit(l2_hit_w),                  //input logic 

    // Outputs to L2
	.arb_mem_read(arb_mem_read_w),      //output logic 
	.arb_mem_write(arb_mem_write_w),    //output logic 
	.arb_pmem_mbe(arb_mbe_w),           //output logic [31:0] 
	.arb_wdata(arb_wdata_w),            //output logic [255:0] 
	.arb_pmem_addr(arb_pmem_addr_w)     //output rv32i_word 
    
);
/*
cacheline_adaptor cad_wo_l2(
    .clk,
    .reset_n(rst),

    // From L2
    .line_i(arb_wdata_w),          //input logic [255:0]
    .address_i(arb_pmem_addr_w),     //input logic [31:0] 
    .read_i(arb_mem_read_w),           //input logic
    .write_i(arb_mem_write_w),         //input logic

    // Outputs to L2 
    .line_o(l2_rdata_w),          //output logic [255:0] 
    .resp_o(l2_resp_w),           //output logic 

    // From Memory
    .burst_i(mem_rdata_top),        //input logic [63:0] 
    .resp_i(mem_resp_top),          //input logic 

    // Outputs to Memory
    .burst_o(mem_wdata_top),        //output logic [63:0] 
    .address_o(mem_addr_top),       //output logic [31:0] 
    .read_o(mem_read_top),          //output logic 
    .write_o(mem_write_top)         //output logic 
);
*/

l2cache l2
(
    .clk,
    .rst,

    /****  CACHE CONTROL  *****/

    // from cacheline adaptor (from PMEM)
    .pmem_resp(pmem_resp_w),                          //input logic 

    // to cacheline adaptor (to PMEM)
    .pmem_read(pmem_read_w),                          //output logic 
    .pmem_write(pmem_write_w),                        //output logic 

    // from Arbiter
    .mem_read(arb_mem_read_w),                        //input logic 
    .mem_write(arb_mem_write_w),                      //input logic 

    // to Arbiter
    .mem_resp(l2_resp_w),                             //output logic 

    /**** CACHE DATAPATH ****/

    // From Arbiter
    .mem_address(arb_pmem_addr_w),                    //input rv32i_word 

    // From CAD
    .pmem_rdata(pmem_rdata_w),                        // input logic [255:0] 

    // to CAD
    .pmem_address(pmem_address_w),                    //output rv32i_word 
    .pmem_wdata(pmem_wdata_w),                        //output logic [255:0] 
    //.hit(l2_hit_w),                                   //output logic 

    /****  BUS ADAPTOR  *****/

    // from Arbiter
    .mem_wdata(arb_wdata_w),                          //input logic [255:0]
    .mem_rdata(l2_rdata_w),                           //output logic [255:0]  
    .mem_byte_enable(arb_mbe_w)                       //input logic [31:0]
); 

cacheline_adaptor arkin_cad(
    .clk,
    .reset_n(rst),

    // From L2
    .line_i(pmem_wdata_w),          //input logic [255:0]
    .address_i(pmem_address_w),     //input logic [31:0] 
    .read_i(pmem_read_w),           //input logic
    .write_i(pmem_write_w),         //input logic

    // Outputs to L2 
    .line_o(pmem_rdata_w),          //output logic [255:0] 
    .resp_o(pmem_resp_w),           //output logic 

    // From Memory
    .burst_i(mem_rdata_top),        //input logic [63:0] 
    .resp_i(mem_resp_top),          //input logic 

    // Outputs to Memory
    .burst_o(mem_wdata_top),        //output logic [63:0] 
    .address_o(mem_addr_top),       //output logic [31:0] 
    .read_o(mem_read_top),          //output logic 
    .write_o(mem_write_top)         //output logic 
);

// add wave -position insertpoint  \
// sim:/mp3_tb/dut/pipeline_core/inst_rdata \
// sim:/mp3_tb/dut/pipeline_core/inst_read \
// sim:/mp3_tb/dut/pipeline_core/inst_addr \
// sim:/mp3_tb/dut/pipeline_core/data_read \
// sim:/mp3_tb/dut/pipeline_core/data_write \
// sim:/mp3_tb/dut/pipeline_core/data_mbe \
// sim:/mp3_tb/dut/pipeline_core/data_addr \
// sim:/mp3_tb/dut/pipeline_core/data_rdata
// add wave -position insertpoint  \
// sim:/mp3_tb/dut/icache/pmem_resp \
// sim:/mp3_tb/dut/icache/pmem_read \
// sim:/mp3_tb/dut/icache/pmem_rdata \
// sim:/mp3_tb/dut/icache/pmem_address \
// sim:/mp3_tb/dut/icache/mem_rdata \
// sim:/mp3_tb/dut/icache/mem_byte_enable
// add wave -position insertpoint  \
// sim:/mp3_tb/dut/dcache/pmem_resp \
// sim:/mp3_tb/dut/dcache/pmem_read \
// sim:/mp3_tb/dut/dcache/pmem_write \
// sim:/mp3_tb/dut/dcache/pmem_rdata \
// sim:/mp3_tb/dut/dcache/pmem_address \
// sim:/mp3_tb/dut/dcache/mem_rdata \
// sim:/mp3_tb/dut/dcache/mem_byte_enable
// add wave -position insertpoint  \
// sim:/mp3_tb/dut/cache_arbiter/arb_irdata \
// sim:/mp3_tb/dut/cache_arbiter/arb_drdata
// add wave -position insertpoint  \
// sim:/mp3_tb/dut/l2/pmem_rdata \
// sim:/mp3_tb/dut/l2/pmem_address

endmodule: mp3
