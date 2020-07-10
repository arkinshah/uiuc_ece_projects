/************************************************************************
Avalon-MM Interface for AES Decryption IP Core

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department

Register Map:

 0-3 : 4x 32bit AES Key
 4-7 : 4x 32bit AES Encrypted Message
 8-11: 4x 32bit AES Decrypted Message
   12: Not Used
	13: Not Used
   14: 32bit Start Register
   15: 32bit Done Register

************************************************************************/

module avalon_aes_interface (
	// Avalon Clock Input
	input logic CLK,

	// Avalon Reset Input
	input logic RESET,

	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,		// Avalon-MM Byte Enable
	input  logic [3:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data

	// Exported Conduit
	output logic [31:0] EXPORT_DATA		// Exported Conduit Signal to LEDs
);

AES aes0(
	input	 logic CLK,
	input  logic RESET,
	input  logic AES_START,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC
);


wire [31:0] temp; //for Writing data


//register wires
wire [31:0] AES_KEY0, AES_KEY1, AES_KEY2, AES_KEY3, AES_MSG_EN0, AES_MSG_EN1, AES_MSG_EN2, AES_MSG_EN3, AES_MSG_DE0, AES_MSG_DE1, AES_MSG_DE2, AES_MSG_DE3, r0, r1, AES_START, AES_DONE;


assign EXPORT_DATA = {AES_MSG_EN0[31:16], AES_MSG_EN3[15:0]} ;

always_comb
begin


case (AVL_BYTE_EN)

4'b1111 : temp = AVL_WRITEDATA;
4'b1100 : temp = {AVL_WRITEDATA[31:16], {16{1'b0}}};
4'b0011 : temp = {{16{1'b0}}, AVL_WRITEDATA[15:0]};
4'b1000 : temp = {AVL_WRITEDATA[31:24], {24{1'b0}}};
4'b0100 : temp = {{8{1'b0}}, AVL_WRITEDATA[23:16], {16{1'b0}}};
4'b0010 : temp = {{16{1'b0}}, AVL_WRITEDATA[15:8], {8{1'b0}}};
4'b0001 : temp = {{24{1'b0}}, AVL_WRITEDATA[7:0]};

default temp = AVL_WRITEDATA;

endcase
end



always_ff @ (posedge CLK)
begin


///////////
if (~RESET) //reset covered
begin
AES_KEY0 <= 32'h00000000;
AES_KEY1 <= 32'h00000000;
AES_KEY2 <= 32'h00000000;
AES_KEY3 <= 32'h00000000;
AES_MSG_EN0 <= 32'h00000000;
AES_MSG_EN1 <= 32'h00000000;
AES_MSG_EN2 <= 32'h00000000;
AES_MSG_EN3 <= 32'h00000000;
AES_MSG_DE0 <= 32'h00000000;
AES_MSG_DE1 <= 32'h00000000;
AES_MSG_DE2 <= 32'h00000000;
AES_MSG_DE3 <= 32'h00000000;
r0 <= 32'h00000000;
r1 <= 32'h00000000;
AES_START <= 32'h00000000;
AES_DONE <= 32'h00000000;
end
////////////

if (AVL_CS)
begin

if (AVL_READ)

begin
case (AVL_ADDR)
4'h0: AVL_READDATA <= AES_KEY0;
4'h1: AVL_READDATA <= AES_KEY1;
4'h2: AVL_READDATA <= AES_KEY2;
4'h3: AVL_READDATA <= AES_KEY3;
4'h4: AVL_READDATA <= AES_MSG_EN0;
4'h5: AVL_READDATA <= AES_MSG_EN1;
4'h6: AVL_READDATA <= AES_MSG_EN2;
4'h7: AVL_READDATA <= AES_MSG_EN3;
4'h8: AVL_READDATA <= AES_MSG_DE0;
4'h9: AVL_READDATA <= AES_MSG_DE1;
4'hA: AVL_READDATA <= AES_MSG_DE2;
4'hB: AVL_READDATA <= AES_MSG_DE3;
4'hC: AVL_READDATA <= r0;
4'hD: AVL_READDATA <= r1;
4'hE: AVL_READDATA <= AES_START;
4'hF: AVL_READDATA <= AES_DONE;
endcase
end

else  //it must be write afterwar1s (only one can be high)


begin
case (AVL_ADDR)

4'h0: AES_KEY0 <= temp | AES_KEY0;
4'h1: AES_KEY1 <= temp | AES_KEY1;
4'h2: AES_KEY2 <= temp | AES_KEY2;
4'h3: AES_KEY3 <= temp | AES_KEY3;
4'h4: AES_MSG_EN0 <= temp | AES_MSG_EN0;
4'h5: AES_MSG_EN1 <= temp | AES_MSG_EN1;
4'h6: AES_MSG_EN2 <= temp | AES_MSG_EN2;
4'h7: AES_MSG_EN3 <= temp | AES_MSG_EN3;
4'h8: AES_MSG_DE0 <= temp | AES_MSG_DE0;
4'h9: AES_MSG_DE1 <= temp | AES_MSG_DE1;
4'hA: AES_MSG_DE2 <= temp | AES_MSG_DE2;
4'hB: AES_MSG_DE3 <= temp | AES_MSG_DE3;
4'hC: r0 <= temp | r0;
4'hD: r1 <= temp | r1;
4'hE: AES_START <= temp | AES_START;
4'hF: AES_DONE <= temp | AES_DONE;
endcase
end



end



end

endmodule
