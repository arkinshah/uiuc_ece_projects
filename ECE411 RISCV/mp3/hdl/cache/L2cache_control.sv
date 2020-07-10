module l2cache_control (

    input clk,
    input rst,

    // from cacheline adaptor (from PMEM)
    input logic resp_o, // pmem_resp

    // to cacheline adaptor (to PMEM)
    output logic read_i, // pmem_read
    output logic write_i, // pmem_write

    // from CPU
    input logic mem_read,
    input logic mem_write,

    // to CPU
    output logic mem_resp,

    // from cache datapath
    input logic hit0,
    input logic valid0_out,
    input logic dirty0_out,

    input logic hit1,
    input logic valid1_out,
    input logic dirty1_out,

    input logic LRU_out,

    // to cache datapath
    output logic load_tag_0,
    output logic load_valid_0,
    output logic load_dirty_0,
    output logic load_data_0,

    output logic load_tag_1,
    output logic load_valid_1,
    output logic load_dirty_1,
    output logic load_data_1,

    output logic way_select,
    output logic valid_in,
    output logic dirty_in,

    output logic load_LRU,
    output logic lru_in, 

    output logic data_select,
    output logic [1:0] pmem_mux_sel
);

enum int unsigned{
    rw,
    write_back,
    pmem
} state, next_state;

function void set_cache_defaults();

    read_i =     1'b0; // pmem read
    write_i =    1'b0; // pmem write

    mem_resp =      1'b0;

    load_tag_0 =    1'b0;
    load_valid_0 =  1'b0;
    load_dirty_0 =  1'b0;
    load_data_0 =   1'b0;

    load_tag_1 =    1'b0;
    load_valid_1 =  1'b0;
    load_dirty_1 =  1'b0;
    load_data_1 =   1'b0;

    valid_in =      1'b0;
    dirty_in =      1'b0;
    way_select =    1'b0;
    load_LRU =      1'b0;
    lru_in =        1'b0; 
    pmem_mux_sel =  2'b00; // default to {mem_address[31:5] , 5'd0}
    data_select =   1'b0;

endfunction

always_comb
begin : state_actions
    /* Default output assignments */
    set_cache_defaults();

    /* Actions for each state */
    case(state)

        rw: begin

            // WRITE

            if (mem_write == 1'b1) begin

                if (hit0 == 1'b1) begin
                    mem_resp = 1'b1;
                    way_select = 1'b0; // choose way 0 because hit
                    load_LRU = 1'b1;
                    lru_in = 1'b1;     // use way1
                    load_dirty_0 = 1'b1;
                    dirty_in = 1'b1;   // data is now dirty
                    data_select = 1'b1;   // load user input data into the array
                    load_data_0 = 1'b1; // load into data array 0
                end

                else if (hit1 == 1'b1) begin
                    mem_resp = 1'b1;
                    way_select = 1'b1; // choose way 1 because hit
                    load_LRU = 1'b1;
                    lru_in = 1'b0;     // use way0
                    load_dirty_1 = 1'b1;
                    dirty_in = 1'b1;   // data is now dirty
                    data_select = 1'b1;   // load user input data into the array
                    load_data_1 = 1'b1; // load into data array 1
                end

                // MISS ??
                else begin
                // WRITE MISS, ACTS AS PSEUDO IDLE STATE
                end

            end    

            // READ

            else if (mem_read == 1'b1) begin

                if (hit0 == 1'b1) begin
                    mem_resp = 1'b1;
                    way_select = 1'b0; // choose way 0 because hit0
                    load_LRU = 1'b1;
                    lru_in = 1'b1; // set way1 as LRU, hit 0 possibly
                end

                else if (hit1 == 1'b1) begin
                    mem_resp = 1'b1;
                    way_select = 1'b1; // choose way 1 because hit1
                    load_LRU = 1'b1;
                    lru_in = 1'b0; // set way0 as LRU, hit 0 possibly
                end

                // MISS
                else begin
                // READ MISS, ACTS AS PSEUDO IDLE STATE
                end

            end

        end

        write_back: begin

            //load_pmem_wdata = 1'b1; 
            write_i = 1'b1; // pmem write

            if (LRU_out == 1'b0) begin 
                pmem_mux_sel = 2'b01; // tag0, index, 5'd0
                load_dirty_0 = 1'b1; 
                dirty_in = 1'b0; // set dirty bit back to 0 because it was copied to pmem
            end

            else begin // if (lru_out == 1'b1) 
                pmem_mux_sel = 2'b10; // tag1, index, 5'd0
                load_dirty_1 = 1'b1;
                dirty_in = 1'b0; // set dirty bit back to 0 because it was copied to pmem
            end

        end

        pmem: begin

            valid_in = 1'b1; // data is now valid because it was either read from pmem (or will be written by user)
            read_i = 1'b1;

            if (LRU_out == 1'b0) begin
                load_tag_0 = 1'b1;
                load_valid_0 = 1'b1;
                load_data_0 = 1'b1;
            end

            else begin // if (lru_out == 1'b1)  
                load_tag_1 = 1'b1;
                load_valid_1 = 1'b1;
                load_data_1 = 1'b1;

            end

        end

        default: ;

    endcase

end  

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */

    next_state = state;

	case(state)

        rw: begin

            // HIT
            if (hit0 == 1'b1 || hit1 == 1'b1) // if hit, go to idle, everything's good
                next_state = rw;

            else if (mem_read == 1'b0 && mem_write == 1'b0)
                next_state = rw;    

            // MISS BUT VALID WAYS  
            else if (valid0_out == 1'b1 && valid1_out == 1'b1) begin 

                if (LRU_out == 1'b0 && dirty0_out == 1'b1) // gotta use way 0 but it's got dirty data
                    next_state = write_back;
                else if (LRU_out == 1'b1 && dirty1_out == 1'b1) // gotta use way 1 but it's got dirty data
                    next_state = write_back;
                else
                    next_state = pmem;	// no dirty data in either of the ways, conflict resolution with way0 as default

			end

            // MISS AND INVALID WAYS (INIT)
            else
                next_state = pmem;
        end

        write_back: begin
            if (resp_o == 1'b1) // mem ready, go to pmem
                next_state = pmem;
            else
                next_state = write_back; // else stay here
        end

        pmem: begin
            if (resp_o == 1'b1) // mem ready, go to idle
                next_state = rw;
            // else if(hit0 == 1'b0 && hit1 == 1'b0)
            //     next_state = rw;
            else    
                next_state = pmem; // else stay here
        end

        default: next_state = rw; // default to idle
    endcase

end    

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
    if(rst) state <= rw;
    else state <= next_state;
end

endmodule : l2cache_control