module invaddroundkey(
input logic [127:0] msg_enc,
input logic [127:0] cipher,
output logic [127:0] roundedkey
);

always_comb
begin
  roundedkey <= msg_enc ^ cipher;
end

endmodule 
