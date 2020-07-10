import rv32i_types::*; /* Import types defined in rv32i_types.sv */

module cache #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(
    input logic clk,
    input logic rst,

    /****  CACHE CONTROL  *****/
    // from cacheline adaptor (from PMEM)
    input logic pmem_resp,

    // to cacheline adaptor (to PMEM)
    output logic pmem_read, // read_i
    output logic pmem_write, // write_i

    // from CPU
    input logic mem_read,
    input logic mem_write,

    // to CPU
    output logic mem_resp,

    /**** CACHE DATAPATH ****/
    // From CPU
    input rv32i_word mem_address,

    // From PMEM or technically Cacheline Adaptor
    input logic [255:0] pmem_rdata, // was pmem_rdata,  256 bit

    // to PMEM or technically Cacheline Adaptor
    output rv32i_word pmem_address, // was address_i
    output logic [255:0] pmem_wdata, // was pmem_wdata, 256 bit
    output logic [31:0] pmem_mbe,

    /****  BUS ADAPTOR  *****/

    // from CPU
    input rv32i_word mem_wdata, 
    output rv32i_word mem_rdata, 
    input logic [3:0] mem_byte_enable
);
    logic [255:0] line_o_w;
    assign line_o_w = pmem_rdata;

    logic [255:0] line_i_w;
    assign pmem_wdata = line_i_w;

    logic [31:0] address_i_w;
    assign pmem_address = address_i_w;

    // CACHE CONTROL
    logic hit0_w;
    logic valid0_out_w;
    logic dirty0_out_w;

    logic hit1_w;
    logic valid1_out_w;
    logic dirty1_out_w;

    logic LRU_out_w;

    // from cacheline adaptor (from PMEM)
    logic resp_o_w;
    assign resp_o_w = pmem_resp;

    // to cacheline adaptor (to PMEM)
    logic read_i_w;
    assign pmem_read = read_i_w; 

    logic write_i_w;
    assign pmem_write = write_i_w; 

    // from CPU
    logic mem_read_w;
    assign mem_read_w = mem_read;

    logic mem_write_w;
    assign mem_write_w = mem_write;

    // to CPU
    logic mem_resp_w;
    assign mem_resp = mem_resp_w;

    // to cache datapath
    logic load_tag_0_w;
    logic load_valid_0_w;
    logic load_dirty_0_w;
    logic load_data_0_w;

    logic load_tag_1_w;
    logic load_valid_1_w;
    logic load_dirty_1_w;
    logic load_data_1_w;

    logic way_select_w;
    logic valid_in_w;
    logic dirty_in_w;

    logic load_LRU_w;
    logic lru_in_w; 

    logic data_select_w;
    logic [1:0] pmem_mux_sel_w; // 2 bit
    logic [1:0] write_en_mux_sel0_w;
    logic [1:0] write_en_mux_sel1_w;

    // BUS ADAPTOR
    logic [255:0] mem_wdata256_w;
    logic [255:0] mem_rdata256_w;
    logic [31:0] mem_byte_enable256_w;
    logic [31:0] mem_wdata_w; // from CPU
    logic [31:0] mem_rdata_w; // to CPU
    logic [3:0] mem_byte_enable_w; // from CPU
    logic [31:0] mem_address_w; // from CPU


    assign mem_wdata_w = mem_wdata;
    assign mem_rdata = mem_rdata_w; // TO CPU
    assign mem_byte_enable_w = mem_byte_enable;
    assign mem_address_w = mem_address;


cache_control cache_control_unit
(
    .clk,
    .rst,

    // from cacheline adaptor (from PMEM)
    .resp_o(resp_o_w),

    // to cacheline adaptor (to PMEM)
    .read_i(read_i_w),
    .write_i(write_i_w),
	 .pmem_mbe,

    // from CPU
    .mem_read(mem_read_w),
    .mem_write(mem_write_w),

    // to CPU
    .mem_resp(mem_resp_w),

    // from cache datapath
    .hit0(hit0_w),
    .valid0_out(valid0_out_w),
    .dirty0_out(dirty0_out_w),

    .hit1(hit1_w),
    .valid1_out(valid1_out_w),
    .dirty1_out(dirty1_out_w),

    .LRU_out(LRU_out_w),

    // to cache datapath
    .load_tag_0(load_tag_0_w),
    .load_valid_0(load_valid_0_w),
    .load_dirty_0(load_dirty_0_w),
    .load_data_0(load_data_0_w),

    .load_tag_1(load_tag_1_w),
    .load_valid_1(load_valid_1_w),
    .load_dirty_1(load_dirty_1_w),
    .load_data_1(load_data_1_w),

    .way_select(way_select_w),
    .valid_in(valid_in_w),
    .dirty_in(dirty_in_w),

    .load_LRU(load_LRU_w),
    .lru_in(lru_in_w), 

    .data_select(data_select_w),
    .pmem_mux_sel(pmem_mux_sel_w) // 2 bit
);

cache_datapath cache_datapath_unit
(
    .clk,
    .rst,

    // From CPU
    .mem_address(mem_address_w),

    // From Bus Adaptor
    .mem_byte_enable256(mem_byte_enable256_w), // write_en 256 bit
    .mem_wdata256(mem_wdata256_w), // 32 bit

    // to Bus Adaptor
    .mem_rdata256(mem_rdata256_w), // 256 bit

    // From PMEM or technically Cacheline Adaptor
    .line_o(line_o_w), // was pmem_rdata,  256 bit

    // to PMEM or technically Cacheline Adaptor
    .address_i(address_i_w), // was pmem_address, 32 bit
    .line_i(line_i_w), // was pmem_wdata, 256 bit

    // from Cache Control
    .load_tag_0(load_tag_0_w),
    .load_valid_0(load_valid_0_w),
    .load_dirty_0(load_dirty_0_w),
    .load_data_0(load_data_0_w),

    .load_tag_1(load_tag_1_w),
    .load_valid_1(load_valid_1_w),
    .load_dirty_1(load_dirty_1_w),
    .load_data_1(load_data_1_w),

    .way_select(way_select_w),
    .valid_in(valid_in_w),
    .dirty_in(dirty_in_w),

    .load_LRU(load_LRU_w),
    .lru_in(lru_in_w), 


    .data_select(data_select_w),
    .pmem_mux_sel(pmem_mux_sel_w), // 2 bit

    // to Cache Control
    .hit0(hit0_w),
    .valid0_out(valid0_out_w),
    .dirty0_out(dirty0_out_w), 

    .hit1(hit1_w),
    .valid1_out(valid1_out_w),
    .dirty1_out(dirty1_out_w),

    .LRU_out(LRU_out_w)
);

bus_adapter bus_adapter
(
    .mem_wdata256(mem_wdata256_w),
    .mem_rdata256(mem_rdata256_w),
    .mem_wdata(mem_wdata_w), // from CPU
    .mem_rdata(mem_rdata_w), // to CPU
    .mem_byte_enable(mem_byte_enable_w), // from CPU
    .mem_byte_enable256(mem_byte_enable256_w),
    .address(mem_address_w) // from CPU
);
    
endmodule : cache