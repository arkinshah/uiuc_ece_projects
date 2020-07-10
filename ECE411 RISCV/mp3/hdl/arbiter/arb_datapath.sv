import rv32i_types::*;

module arb_datapath(
        
        input logic clk,
        input logic rst,

        // From Cache to Arbiter (L2)
        input rv32i_word icache_address,
        input logic [255:0] icache_wdata,
        input logic i_read,
        input logic i_write,
        input logic [31:0] icache_mbe,

        input rv32i_word dcache_address,
        input logic [255:0] dcache_wdata,
        input logic d_read,
        input logic d_write,
        input logic [31:0] dcache_mbe, 

        // From L2 to Arbiter
        input logic [255:0] l2_rdata,
        input logic l2_resp,

        // From Arbiter Control to Arbiter Datapath
        input logic [1:0] read_mux_sel,
        input logic [1:0] write_mux_sel,
        input logic [1:0] addr_mux_sel,
        input logic rdata_mux_sel,
        input logic wdata_mux_sel,
        input logic mbe_mux_sel,
        input logic [1:0] resp_mux_sel,

        // Outputs to Caches Above
	    output logic [255:0] arb_irdata,
        output logic arb_iresp,
	    output logic [255:0] arb_drdata,
	    output logic arb_dresp,

        // Outputs to Cacheline Adaptor Below
	    output logic arb_mem_read,
	    output logic arb_mem_write,
	    output logic [31:0] arb_pmem_mbe,
	    output logic [255:0] arb_wdata,
	    output rv32i_word arb_pmem_addr
);

rv32i_word prefetch_address;

always_ff @(posedge clk) begin
	if (rst)
		prefetch_address <= '0;
	else if (i_read && (addr_mux_sel != 2'b10))
		prefetch_address <= icache_address + 8'h20;
	else
		prefetch_address <= prefetch_address;
end

always_comb
begin: MUXES

    // It looks like D-Cache gets priority but it is just so that conflicts
    // are handled properly -- D-Cache gets its data and then the state machine
    // allows access to I-Cache

    unique case(read_mux_sel)
        2'b00: arb_mem_read = d_read;
        2'b01: arb_mem_read = i_read;
        2'b10: arb_mem_read = 1'b1;
		  2'b11: arb_mem_read = 1'b0;
        default: arb_mem_read = 1'b0;
    endcase

    unique case(write_mux_sel)
        2'b00: arb_mem_write = d_write;
        2'b01: arb_mem_write = i_write;
        2'b10, 2'b11: arb_mem_write = 1'b0;
        default: arb_mem_write = 1'b0;
    endcase

    unique case(addr_mux_sel)
        2'b00: arb_pmem_addr = dcache_address;
        2'b01: arb_pmem_addr = icache_address;
		  2'b10: arb_pmem_addr = prefetch_address;
        default: arb_pmem_addr = 32'd0;
    endcase

    unique case(rdata_mux_sel)

        1'b0: begin

            //if(d_read) begin
                arb_irdata = 256'd0;
                arb_drdata = l2_rdata;
            //end 

            //else begin
            //    arb_irdata = 256'd0;
            //    arb_drdata = 256'd0;
            //end   
        end

        1'b1: begin

           // if(i_read) begin
                arb_irdata = l2_rdata;
                arb_drdata = 256'd0;
           // end

            //else begin
            //    arb_irdata = 256'd0;
            //    arb_drdata = 256'd0;
            //end

        end

        default: begin
        arb_irdata = 256'd0;
        arb_drdata = 256'd0;
        end

    endcase

    unique case(wdata_mux_sel)
        1'b0: arb_wdata = dcache_wdata;
        1'b1: arb_wdata = icache_wdata;
        default: arb_wdata = 256'd0;
    endcase
    
    unique case(mbe_mux_sel)
        1'b0: arb_pmem_mbe = dcache_mbe;
        1'b1: arb_pmem_mbe = icache_mbe;
        default: arb_pmem_mbe = 32'd0;
    endcase
    
    unique case(resp_mux_sel)
        1'b0: begin
        arb_dresp = l2_resp;
        arb_iresp = 1'b0;
        end

        1'b1: begin
        arb_dresp = 1'b0;
        arb_iresp = l2_resp;
        end

        default: begin
        arb_dresp = 1'b0;
        arb_iresp = 1'b0;
        end

    endcase


end


endmodule: arb_datapath
