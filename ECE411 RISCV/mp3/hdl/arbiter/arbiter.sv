import rv32i_types::*;

module arbiter(
    input logic clk,
    input logic rst,

    // From Caches to Arbiter
    input logic i_read,
    input logic i_write,
    input logic d_read,
    input logic d_write,

    input rv32i_word icache_address,
    input logic [255:0] icache_wdata,
    input logic [31:0] icache_mbe,

    input rv32i_word dcache_address,
    input logic [255:0] dcache_wdata,
    input logic [31:0] dcache_mbe,

    // Outputs to Caches Above
	output logic [255:0] arb_irdata,
    output logic arb_iresp,
	output logic [255:0] arb_drdata,
	output logic arb_dresp,

    // From L2 to Arbiter
    input logic [255:0] l2_rdata,
    input logic l2_resp,
    input logic l2_hit,

    // Outputs to L2 Below
	output logic arb_mem_read,
	output logic arb_mem_write,
	output logic [31:0] arb_pmem_mbe,
	output logic [255:0] arb_wdata,
	output rv32i_word arb_pmem_addr
    
);

logic [1:0] rmux_sel, wmux_sel, addrmux_sel, respmux_sel;
logic rdatamux_sel, wdatamux_sel, mbemux_sel;

arb_control arbiter_control(

        .clk,
        .rst,

        // From Caches to Arbiter
        .i_read,    //input logic 
        .i_write,   //input logic 
        .d_read,    //input logic 
        .d_write,   //input logic 
        
        // From L2 (Cacheline Adaptor) to Arbiter
        .l2_hit,                        //input logic 
        .l2_resp,                       //input logic

        // From Arbiter Control to Arbiter Datapath
        .read_mux_sel(rmux_sel),                  //output logic [1:0] 
        .write_mux_sel(wmux_sel),                 //output logic [1:0] 
        .addr_mux_sel(addrmux_sel),               //output logic 
        .rdata_mux_sel(rdatamux_sel),             //output logic 
        .wdata_mux_sel(wdatamux_sel),             //output logic 
        .mbe_mux_sel(mbemux_sel),                 //output logic 
        .resp_mux_sel(respmux_sel)                //output logic 
);

arb_datapath arbiter_datapath(
        
        .clk,
        .rst,

        // From Cache to Arbiter (L2)
        .icache_address,    //input rv32i_word 
        .icache_wdata,      //input [255:0]
        .i_read,            //input logic 
        .i_write,           //input logic 
        .icache_mbe,        //input logic [31:0] 

        .dcache_address,    //input rv32i_word 
        .dcache_wdata,      //input [255:0] 
        .d_read,            //input logic 
        .d_write,           //input logic 
        .dcache_mbe,        //input logic [31:0] 

        // From L2 (Cacheline Adaptor) to Arbiter
        .l2_rdata,          //input rv32i_word 
        .l2_resp,           //input logic 

        // From Arbiter Control to Arbiter Datapath
        .read_mux_sel(rmux_sel),            //input logic [1:0] 
        .write_mux_sel(wmux_sel),           //input logic [1:0] 
        .addr_mux_sel(addrmux_sel),         //input logic 
        .rdata_mux_sel(rdatamux_sel),       //input logic 
        .wdata_mux_sel(wdatamux_sel),       //input logic 
        .mbe_mux_sel(mbemux_sel),           //input logic 
        .resp_mux_sel(respmux_sel),          //input logic 

        // Outputs to Caches Above
	    .arb_irdata,        //output [255:0]
        .arb_iresp,         //output logic 
	    .arb_drdata,        //output [255:0] 
	    .arb_dresp,         //output logic 

        // Outputs to Cacheline Adaptor Below
	    .arb_mem_read,      //output logic 
	    .arb_mem_write,     //output logic 
	    .arb_pmem_mbe,      //output logic [3:0]
	    .arb_wdata,         //output rv32i_word 
	    .arb_pmem_addr      //output rv32i_word 
);


endmodule: arbiter
