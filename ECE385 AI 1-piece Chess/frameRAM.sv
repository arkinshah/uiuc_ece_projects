/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  frameRAM
(
		input [4:0] data_In,
		input [18:0] read_address,
		input  Clk,

		output logic [4:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses
logic [23:0] idle [0:1023]; //player idle (NORTH)
logic [23:0] idle1[0:1023]; //player idle (SOUTH)
logic [23:0] idle2 [0:1023]; //player idle (EAST)
logic [23:0] idle3 [0:1023]; //player idle (WEST)
logic [23:0] walkN [0:1023]; //player walk1 (NORTH)
logic [23:0] walkN1[0:1023]; //player walk2 (NORTH)
logic [23:0] walkS [0:1023]; //player walk1 (South)
logic [23:0] walkS1[0:1023]; //player walk2 (South)
logic [23:0] walkE [0:1023]; //player walk1 (East)
logic [23:0] walkE1[0:1023]; //player walk2 (East)
logic [23:0] walkW [0:1023]; //player walk1 (West)
logic [23:0] walkW1[0:1023]; //player walk2 (West)

logic [23:0] mIdle [0:1023]; 
logic [23:0] mIdle1 [0:1923]; 
logic [23:0] mIdle2 [0:1023]; 
logic [23:0] mIdle3 [0:1023]; 
logic [23:0] mwalkN [0:1023]; //player walk1 (NORTH)
logic [23:0] mwalkN1[0:1023]; //player walk2 (NORTH)
logic [23:0] mwalkS [0:1023]; //player walk1 (South)
logic [23:0] mwalkS1[0:1023]; //player walk2 (South)
logic [23:0] mwalkE [0:1023]; //player walk1 (East)
logic [23:0] mwalkE1[0:1023]; //player walk2 (East)
logic [23:0] mwalkW [0:1023]; //player walk1 (West)
logic [23:0] mwalkW1[0:1023]; //player walk2 (West)

logic [23:0] blood[0:1023];


initial
begin
	 $readmemh("sprite_bytes/tetris_I.txt", idle);
	 $readmemh("sprite_bytes/tetris_I.txt", idle1);
	 $readmemh("sprite_bytes/tetris_I.txt", idle2);
	 $readmemh("sprite_bytes/tetris_I.txt", idle3);
	 $readmemh("sprite_bytes/tetris_I.txt", walkN);
	 $readmemh("sprite_bytes/tetris_I.txt", walkN1);
	 $readmemh("sprite_bytes/tetris_I.txt", walkS);
	 $readmemh("sprite_bytes/tetris_I.txt", walkS1);
	 $readmemh("sprite_bytes/tetris_I.txt", walkE);
	 $readmemh("sprite_bytes/tetris_I.txt", walkE1);
	 $readmemh("sprite_bytes/tetris_I.txt", walkW);
	 $readmemh("sprite_bytes/tetris_I.txt", walkW1);
	 $readmemh("sprite_bytes/tetris_I.txt", mIdle);
	 $readmemh("sprite_bytes/tetris_I.txt", mIdle1);
	 $readmemh("sprite_bytes/tetris_I.txt", mIdle2);
	 $readmemh("sprite_bytes/tetris_I.txt", mIdle3);
	 $readmemh("sprite_bytes/tetris_I.txt", mwalkN);
	 $readmemh("sprite_bytes/tetris_I.txt", mwalkN1);
	 $readmemh("sprite_bytes/tetris_I.txt", mwalkS);
	 $readmemh("sprite_bytes/tetris_I.txt", mwalkS1);
	 $readmemh("sprite_bytes/tetris_I.txt", mwalkW);
	 $readmemh("sprite_bytes/tetris_I.txt", mwalkW1);
	 $readmemh("sprite_bytes/tetris_I.txt", mwalkE);
	 $readmemh("sprite_bytes/tetris_I.txt", mwalkE1);
	 $readmemh("sprite_bytes/tetris_I.txt", mwalkN);
	 $readmemh("sprite_bytes/tetris_I.txt", mwalkN1);
	 
	 
	 
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];
end

endmodule
