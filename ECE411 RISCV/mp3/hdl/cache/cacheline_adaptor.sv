module cacheline_adaptor
(
    input clk,
    input reset_n,

    // Port to LLC (Lowest Level Cache)
    input logic [255:0] line_i,
    output logic [255:0] line_o,
    input logic [31:0] address_i,
    input read_i,
    input write_i,
    output logic resp_o,

    // Port to memory
    input logic [63:0] burst_i,
    output logic [63:0] burst_o,
    output logic [31:0] address_o,
    output logic read_o,
    output logic write_o,
    input resp_i
);

enum int unsigned{
    idle, reset,
    read1, read2, read3, read4, readDone,
    write1, write2, write3, write4, writeDone
} state, next_state;

//logic [63:0] temp1, temp2, temp3, temp4;
//assign line_o = {temp4, temp3, temp2, temp1};
logic [255:0] line_otemp;

always_ff @(posedge clk) begin

    if(state == readDone) begin
        line_o <= line_o;
    end

    else begin
        line_o <= line_otemp;
    end

end

//logic flag;

// logic tread_o, twrite_o;
// assign read_o = tread_o;
// assign write_o = twrite_o;

always_comb
begin
    read_o = 1'b0;

    case(state)
        read1: read_o = 1'b1;
        read2: read_o = 1'b1;
        read3: read_o = 1'b1;
        read4: read_o = 1'b1;
        readDone: read_o = 1'b0;
        idle: read_o = read_i;
        default: read_o = 1'b0;
    endcase

    write_o = 1'b0;

    case(state)
        write1: write_o = 1'b1;
        write2: write_o = 1'b1;
        write3: write_o = 1'b1;
        write4: write_o = 1'b1;
        writeDone: write_o = 1'b0;
        idle: write_o = write_i;
        default: write_o = 1'b0;
    endcase

    //if(read_o == 1'b1) tread_o = 1'b1;
    //if (write_o == 1'b1) twrite_o = 1'b1;
    
end


always_comb
begin : state_actions

    resp_o = 1'b0;
    burst_o = 64'd0;
    address_o = address_i;
    line_otemp = line_o;
    //read_o <= 1'b0;
    //write_o <= 1'b0;

//	temp1 = 64'd0;
//	temp2 = 64'd0;
//	temp3 = 64'd0;
//	temp4 = 64'd0;

    case(state)

        idle: begin
            //read_o <= 1'b0;
            //write_o <= 1'b0;
            resp_o = 1'b0;
            burst_o = 64'd0;

            //read_o = read_i;
        end

        reset: begin
            //read_o = 1'b0;
            //write_o = 1'b0;
            line_otemp = 256'd0;
        end

        read1: begin // burst_i to line_o
            //temp1 = burst_i;
            //read_o <= 1'b1;
            if(resp_i == 1'b1)
            line_otemp = {line_otemp[255:64], burst_i};
        end

        read2: begin // burst_i to line_o
            //temp2 = burst_i;
            //read_o <= 1'b1;
            line_otemp = {line_otemp[255:128], burst_i, line_otemp[63:0]};
        end

        read3: begin // burst_i to line_o
            //temp3 = burst_i;
            //read_o <= 1'b1;
            line_otemp = {line_otemp[255:192], burst_i, line_otemp[127:0]};
        end

        read4: begin // burst_i to line_o
            //temp4 = burst_i;
            //read_o <= 1'b1;
            line_otemp = {burst_i, line_otemp[191:0]};
        end

        readDone: begin
            //flag = 1'b1;
            resp_o = 1'b1;
            //read_o <= 1'b1;
        end

        write1: begin // line_i to burst_o
            burst_o = line_i[63:0];
            //write_o <= 1'b1;
        end

        write2: begin // line_i to burst_o
            burst_o = line_i[127:64];
            //write_o <= 1'b1;
        end

        write3: begin // line_i to burst_o
            burst_o = line_i[191:128];
            //write_o <= 1'b1;
        end

        write4: begin // line_i to burst_o
            burst_o = line_i[255:192];
            //write_o <= 1'b1;
        end

        writeDone: begin
            resp_o = 1'b1;
            //write_o <= 1'b1;
        end

        default: ;

    endcase

end

always_comb
begin : next_state_logic

    next_state = state;

    if(read_i == 1'b1 && write_i == 1'b1) next_state = reset;

    case(state)

        idle: begin
            if(read_i == 1'b1) next_state = read1;
            else if (write_i == 1'b1) next_state = write1;
            else next_state = idle;
        end

        reset: begin
            next_state = idle;
        end

        read1: begin
            if(resp_i == 1'b1) next_state = read2;
        end

        read2: begin
            next_state = read3;
        end

        read3: begin
            next_state = read4;
        end

        read4: begin
            next_state = readDone;
        end

        readDone: begin
            if(resp_i == 1'b0) next_state = idle;
            
        end

        write1: begin
            if(resp_i == 1'b1) next_state = write2;
        end

        write2: begin
            next_state = write3;
        end

        write3: begin
            next_state = write4;
        end

        write4: begin
            next_state = writeDone;
        end

        writeDone: begin
            if(resp_i == 1'b0) next_state = idle;
        end

        default: next_state = idle;
        
    endcase

end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
    if(reset_n) state <= reset;
    else state <= next_state;
end

endmodule : cacheline_adaptor
