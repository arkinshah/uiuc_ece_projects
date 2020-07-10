/************************************************************************
AES Decryption Core Logic

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

module AES (
	input	 logic CLK,
	input  logic RESET,
	input  logic AES_START,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC
);

logic [1407:0] decrypt_key;
logic [1:0] regmux, mcmux;

KeyExpansion keymaker(.clk(CLK), .Cipherkey(AES_KEY), .KeySchedule(decrypt_key));

//instantiate fsm

FSM control_unit(.CLK(CLK), .RST(RESET), .AES_START(AES_START), .AES_DONE(AES_DONE), .REGMUX(regmux), .MIXCOLMUX(mcmux));

// instantiate all the inverse modules in here

invaddroundkey irk(.msg_enc(), .cipher(), .roundedkey());

InvShiftRows isr(input logic [127:0] .data_in(), output logic [127:0] .data_out());

InvSubBytes isb( .clk, input  logic [7:0] .in(), output logic [7:0] .out());

InvMixColumns imc(input  logic [31:0] .in(), output logic [31:0] .out());



















/*
logic counter[16:0]; // could make it 16 bits only but we think its 17 because it took 178662 ps
enum logic[1:0] {HALT, PROCESS, BEGIN} state, next_state;

always_ff @ (posedge CLK)
begin

	if(RESET)
	begin
		counter <= 16'b0;
		state <= HALT;
	end

	else
	begin
		state <= next_state;
		if(state == PROCESS)
		begin
			counter <= 1'b1 + counter;
		end
	end

end

always_comb
begin

	next_state = state;

	case(state)
		BEGIN:
			begin
				AES_DONE = 1'b1;
			end

		HALT:
			begin
				AES_DONE = 1'b0;
				if(AES_START) next_state = PROCESS;
			end

		PROCESS:
				begin
					AES_DONE = 1'b0;
					if(counter==16'd131071) next_state = BEGIN; // this is 2^17, for reference 2^16 = 65536
				end
	endcase

end

*/

endmodule
