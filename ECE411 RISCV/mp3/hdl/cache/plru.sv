module plru
(
    input logic clk,
    input logic rst,
    input logic load,
    input logic [2:0] treein,
    output logic [2:0] treeout,
    output logic [1:0] plru_out
);

/*
    Explanation:
    Lecture 6, Slide 18
    AB/CD = 0/1
    A/B = 0/1
    C/D = 0/1
    if access =   C    D    A    B    A    C    B    D
    Tree =       1X0, 1X1, 001, 011, 001, 100, 010, 111
    Therefore,   A = 00X, B = 01X, C = 1X0, D = 1X1
    Where X's are don't cares.
*/


always_ff @(posedge clk)
begin

    if(rst) begin
        treeout <= 3'd0;
        plru_out <= 2'd0;
    end

    else if(load) begin
        if((treein[2]==1'b0) && (treein[1]==1'b0)) begin
            treeout <= {2'b11, treein[0]};
            plru_out <= 2'd0;
        end

        else if((treein[2]==1'b0) && (treein[1]==1'b1)) begin
            treeout <= {2'b10, treein[0]};  
            plru_out <= 2'd1;
        end

        else if((treein[2]==1'b1) && (treein[0]==1'b0)) begin
            treeout <= {1'b0, treein[1], 1'b1};
            plru_out <= 2'd2;
        end

        else if((treein[2]==1'b1) && (treein[0]==1'b1)) begin
            treeout <= {1'b0, treein[1], 1'b0}; 
            plru_out <= 2'd3;
        end

        else begin
            treeout <= 3'd0;
            plru_out <= 2'd0;
        end

    end

    else begin
        //treeout <= 3'd0;
        //plru_out <= 2'd0;
    end
	
end

/*
always_ff @(posedge clk)
begin

    if(rst) begin
        treeout <= 3'd0;
        plru_out <= 2'd0;
    end

end
*/    

endmodule : plru
