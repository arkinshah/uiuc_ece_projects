
module comparator #(
    parameter width = 24
) 
(
    input [width-1:0] in1,
    input [width-1:0] in2,
    input valid_bit,
    output logic comp_out
);

assign comp_out = (in1 == in2) & valid_bit;

endmodule : comparator

