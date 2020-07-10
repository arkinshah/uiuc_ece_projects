//import rv32i_types::*;

module arb_control(

        input logic clk,
        input logic rst,

        // From Caches to Arbiter
        input logic i_read,
        input logic i_write,
        input logic d_read,
        input logic d_write,
        
        // From L2 (Cacheline Adaptor) to Arbiter
        input logic l2_hit,
        input logic l2_resp,

        // From Arbiter Control to Arbiter Datapath
        output logic [1:0] read_mux_sel,
        output logic [1:0] write_mux_sel,
        output logic [1:0] addr_mux_sel,
        output logic rdata_mux_sel,
        output logic wdata_mux_sel,
        output logic mbe_mux_sel,
        output logic [1:0] resp_mux_sel
);

enum int unsigned{
    idle,
    conflict,
    ic_access,
    dc_access,
	 prefetch
} state, next_state;

function void set_arb_defaults();

    read_mux_sel = 2'b11; // No r/w signal to L2
    write_mux_sel = 2'b11; // No r/w signal to L2
    addr_mux_sel = 1'b0;
    rdata_mux_sel = 1'b0;
    wdata_mux_sel = 1'b0;
    mbe_mux_sel = 1'b0;
    resp_mux_sel = 1'b0; 

endfunction

always_comb
begin: state_actions

    set_arb_defaults();

    case(state)

        idle: begin
            // No r/w, keep L2 Idle as well
        end

        conflict: begin
            // Let D-Cache Access till L2 resp is received
            read_mux_sel = 2'b00;
            write_mux_sel = 2'b00;
        end

        ic_access: begin
            read_mux_sel = 2'b01;
            write_mux_sel = 2'b01;
            addr_mux_sel = 2'b01;
            rdata_mux_sel = 1'b1;
            wdata_mux_sel = 1'b1;
            mbe_mux_sel = 1'b1;
            resp_mux_sel = 1'b1;
        end

        dc_access: begin
            read_mux_sel = 2'b00;
            write_mux_sel = 2'b00;
        end
		  
		  prefetch: begin
				read_mux_sel = 2'b10;
            write_mux_sel = 2'b10;
            addr_mux_sel = 2'b10;
            rdata_mux_sel = 1'b1;
            wdata_mux_sel = 1'b1;
            mbe_mux_sel = 1'b1;
            resp_mux_sel = 2'b10;
		  end

    endcase

end

always_comb
begin: next_state_logic

    next_state = state;

    case(state)

        idle: begin

            // Currently D-Cache is given default access to L2

            // Both trying to r/w
            if ((i_read || i_write) && (d_read || d_write))
                next_state = conflict;

            // Only I-Cache trying to gain access    
            else if (i_read || i_write)
                next_state = ic_access;

            // Only D-Cache trying to gain access   
            else if ((d_read || d_write))
                next_state = dc_access;

            // Stay in Idle state
            else
                next_state = idle;           
        end

        conflict: begin

            // Give I-Cache Priority
            if (!l2_resp)
                next_state = conflict;
            else
                next_state = ic_access;   

        end

        ic_access: begin

            // Can transition to D-Cache as a way to avoid conflict or quick access
            if ((l2_resp) && (d_read || d_write))
                next_state = dc_access;

            // Go back to Idle to handle immediate conflicts in case I-Cache tries again    
            else if ((l2_resp) && (!(d_read || d_write)))   
                next_state = prefetch;

            // No response from L2, stay in state    
            else
                next_state = ic_access;   

        end

        dc_access: begin

            // Need to account for possible conflict, so send it back to idle
            // so that I-Cache can eventually gets its turn once conflict is resolved
            // if (!l2_resp)
            //     next_state = dc_access;
            // else
            //     next_state = idle;    
            // Can transition to I-Cache as a way to avoid conflict or quick access
            if ((l2_resp) && (i_read || i_write))
                next_state = ic_access;

            // Go back to Idle to handle immediate conflicts in case I-Cache tries again    
            else if ((l2_resp) && (!(i_read || i_write)))   
                next_state = idle;

            // No response from L2, stay in state    
            else
                next_state = dc_access;      
        end
		  
		  prefetch: begin
            // Go back to Idle to handle immediate conflicts in case I-Cache tries again    
            if (l2_resp)   
                next_state = idle;

            // No response from L2, stay in state    
            else
                next_state = prefetch; 
		  end

    endcase

end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
    if(rst) state <= idle;
    else state <= next_state;
end

endmodule: arb_control
