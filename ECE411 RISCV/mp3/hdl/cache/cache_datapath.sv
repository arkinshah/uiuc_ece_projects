module cache_datapath #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(
    input clk,
    input rst,

    // From CPU
    input logic [31:0] mem_address,

    // From Bus Adaptor
    input logic [31:0] mem_byte_enable256, // write_en
    input logic [255:0] mem_wdata256,

    // to Bus Adaptor
    output logic [255:0] mem_rdata256, // was mem_rdata but made no sense

    // From PMEM or technically Cacheline Adaptor
    input logic [255:0] line_o, // was pmem_rdata

    // to PMEM or technically Cacheline Adaptor
    output logic [31:0] address_i, // was pmem_address
    output logic [255:0] line_i, // was pmem_wdata

    // from Cache Control
    input logic load_tag_0,
    input logic load_valid_0,
    input logic load_dirty_0,
    input logic load_data_0,

    input logic load_tag_1,
    input logic load_valid_1,
    input logic load_dirty_1,
    input logic load_data_1,

    input logic way_select,
    input logic valid_in,
    input logic dirty_in,

    input logic load_LRU,
    input logic lru_in, 


    input logic data_select,
    input logic [1:0] pmem_mux_sel,

    // to Cache Control
    output logic hit0,
    output logic valid0_out,
    output logic dirty0_out, 

    output logic hit1,
    output logic valid1_out,
    output logic dirty1_out,

    output logic LRU_out
);

logic [23:0]tag_in;
logic [2:0] index;
logic [4:0] offset;
logic [23:0] tag0_out, tag1_out;
logic [255:0] data0, data1, to_data_array;
logic [31:0] write_en0, write_en1;

assign tag_in = mem_address[31:8];
assign index = mem_address[7:5];
assign write_en0 = load_tag_0 ? {32{load_data_0}} : {mem_byte_enable256 & {32{load_data_0}}};
assign write_en1 = load_tag_1 ? {32{load_data_1}} : {mem_byte_enable256 & {32{load_data_1}}};

data_array data0_array
(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .write_en(write_en0),
    .rindex(index),
    .windex(index),
    .datain(to_data_array),
    .dataout(data0)
);

array #(3, 24) tag0_array
(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(load_tag_0),
    .rindex(index),
    .windex(index),
    .datain(tag_in),
    .dataout(tag0_out)
);

array valid0_array
(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(load_valid_0),
    .rindex(index),
    .windex(index),
    .datain(valid_in), 
    .dataout(valid0_out)
);

array dirty0_array
(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(load_dirty_0),
    .rindex(index),
    .windex(index),
    .datain(dirty_in),
    .dataout(dirty0_out)
);

comparator comparator0
(
    .in1(tag_in),
    .in2(tag0_out),
    .valid_bit(valid0_out),
    .comp_out(hit0)
);

data_array data1_array
(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .write_en(write_en1),
    .rindex(index),
    .windex(index),
    .datain(to_data_array),
    .dataout(data1)
);

array #(3, 24) tag1_array
(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(load_tag_1),
    .rindex(index),
    .windex(index),
    .datain(tag_in),
    .dataout(tag1_out)
);

array valid1_array
(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(load_valid_1),
    .rindex(index),
    .windex(index),
    .datain(valid_in),
    .dataout(valid1_out)
);

array dirty1_array
(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(load_dirty_1),
    .rindex(index),
    .windex(index),
    .datain(dirty_in),
    .dataout(dirty1_out)
);

comparator comparator1
(
    .in1(tag_in),
    .in2(tag1_out),
    .valid_bit(valid1_out),
    .comp_out(hit1)
);

array LRU_array
(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(load_LRU),
    .rindex(index),
    .windex(index),
    .datain(lru_in),
    .dataout(LRU_out)
);

always_comb
begin: MUXES

    // Choose which address to send to pmem to write-back into
    unique case(pmem_mux_sel) // address_i was pmem_add
        2'b00: address_i = {mem_address[31:5], 5'd0};
        2'b01: address_i = {tag0_out, index, 5'd0};
        2'b10: address_i = {tag1_out, index, 5'd0};
        default: address_i = {mem_address[31:5], 5'd0};
    endcase

    // Choose which data to send to pmem to write-back into
    unique case(LRU_out)
        1'b0: line_i = data0;
        1'b1: line_i = data1;
        default: line_i = data0;
    endcase

    unique case(data_select)
        1'b0: to_data_array = line_o; // pmem_rdata
        1'b1: to_data_array = mem_wdata256; // was cache_out
        default: to_data_array = line_o; // pmem_rdata
    endcase

    // if hit, return data array data to CPU
    if(hit0 || hit1) begin
        unique case(way_select)
            1'b0: mem_rdata256 = data0; 
            1'b1: mem_rdata256 = data1;
            default: mem_rdata256 = data0;
        endcase
    end
    // if miss, put pmem data in cache and then return to CPU
    else begin
        mem_rdata256 = line_o;
    end

end


endmodule : cache_datapath