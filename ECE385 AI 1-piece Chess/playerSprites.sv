//module spritePlayerIdleNorth(
//		input [18:0] read_address, //the location of where we want the sprite
//		input  Clk,
//		output logic [23:0] data_Out //the output of the sprite
//);
//
//	logic [23:0] idle [1023:0];
//
//	initial
//	begin
//		$readmemh("sprite_bytes/sprite_03.txt", idle);
//	end
//	
//	always_ff @ (posedge Clk) begin
//		data_Out<= idle[read_address];
//	end
//
//
//endmodule
//
//
//module playerWalkNorth(
//	input [18:0] read_address1
//	input Clk,
//	output logic [23:0] walk1, walk2
//);
//
//logic [23:0] ani1 [1023:0];
//logic [23:0] ani2 [1023:0];
//
//initial 
//begin
//	$readmemh("sprite_bytes/sprite_00",ani1);
//	$readmemh("sprite_bytes/sprite_01",ani2);
//end 
//always_ff @ (posedge Clk) begin
//	walk1 <= ani1[read_address1];
//	walk2 <= ani2[read_address1];
//end
//
//
//endmodule
//
//
//module spritePlayerIdleSouth(
//		input [18:0] read_address1
//		input  Clk,
//		output logic [23:0] data_Out
//);
//
//	logic [23:0] idle [1023:0];
//
//	initial
//	begin
//		$readmemh("sprite_bytes/sprite_07.txt", idle);
//	end
//	
//	always_ff @ (posedge Clk) begin
//		data_Out<= idle[read_address];
//	end
//
//
//endmodule
//
//
//module playerWalkSouth(
//	input [18:0] read_address1
//	input Clk,
//	output logic [23:0] walk1, walk2
//
//);
//
//logic [23:0] ani1 [1023:0];
//logic [23:0] ani2 [1023:0];
//
//initial 
//begin
//	$readmemh("sprite_bytes/sprite_04",ani1);
//	$readmemh("sprite_bytes/sprite_05",ani2);
//end 
//always_ff @ (posedge Clk) begin
//	walk1 <= ani1[read_address1];
//	walk2 <= ani2[read_address1];
//end
//
//endmodule
//
//
//module spritePlayerIdleEast(
//		input [18:0] read_address,
//		input  Clk,
//		output logic [23:0] data_Out
//);
//
//	logic [23:0] idle [1023:0];
//
//	initial
//	begin
//		$readmemh("sprite_bytes/sprite_11.txt", idle);
//	end
//	
//	always_ff @ (posedge Clk) begin
//		data_Out<= idle[read_address];
//	end
//
//
//endmodule
//
//
//module playerWalkEast(
//	input [18:0] read_address1
//	input Clk,
//	output logic [23:0] walk1, walk2
//
//);
//logic [23:0] ani1 [1023:0];
//logic [23:0] ani2 [1023:0];
//
//initial 
//begin
//	$readmemh("sprite_bytes/sprite_08",ani1);
//	$readmemh("sprite_bytes/sprite_09",ani2);
//end 
//always_ff @ (posedge Clk) begin
//	walk1 <= ani1[read_address1];
//	walk2 <= ani2[read_address1];
//end
//
//
//endmodule
//
//module spritePlayerIdleWest(
//		input [18:0] read_address,
//		input  Clk,
//		output logic [23:0] data_Out
//);
//
//	logic [23:0] idle [1023:0];
//
//	initial
//	begin
//		$readmemh("sprite_bytes/sprite_15.txt", idle);
//	end
//	
//	always_ff @ (posedge Clk) begin
//		data_Out<= idle[read_address];
//	end
//
//
//endmodule
//
//
//module playerWalkWest(
//	input [18:0] read_address1,
//	input Clk,
//	output logic [23:0] walk1, walk2
//);
//
//initial 
//begin
//	$readmemh("sprite_bytes/sprite_12",ani1);
//	$readmemh("sprite_bytes/sprite_13",ani2);
//end 
//always_ff @ (posedge Clk) begin
//	walk1 <= ani1[read_address1];
//	walk2 <= ani2[read_address1];
//end
//
//endmodule




////say I have an output sprite to detect
////output = x
///
//
//spriteIdle abcd(.read,.data_out(idleX)
//
//
//output x
//
//
//case(10
//	x = idlex