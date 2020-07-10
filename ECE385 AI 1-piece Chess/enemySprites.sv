//module spriteEnemyIdleNorth(
//		input [18:0] read_address, //the location of where we want the sprite
//		input  Clk,
//		output logic [23:0] data_Out //the output of the sprite
//);
//
//	logic [23:0] idle [1023:0];
//
//	initial
//	begin
//		$readmemh("sprite_bytes/sprite_30.txt", idle);
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
//module enemyWalkNorth(
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
//	$readmemh("sprite_bytes/sprite_28",ani1);
//	$readmemh("sprite_bytes/sprite_29",ani2);
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
//module spriteEnemyIdleSouth(
//		input [18:0] read_address1
//		input  Clk,
//		output logic [23:0] data_Out
//);
//
//	logic [23:0] idle [1023:0];
//
//	initial
//	begin
//		$readmemh("sprite_bytes/sprite_19.txt", idle);
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
//module enemyWalkSouth(
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
//	$readmemh("sprite_bytes/sprite_16",ani1);
//	$readmemh("sprite_bytes/sprite_17",ani2);
//end 
//always_ff @ (posedge Clk) begin
//	walk1 <= ani1[read_address1];
//	walk2 <= ani2[read_address1];
//end
//
//endmodule
//
//
//module spriteEnemyIdleEast(
//		input [18:0] read_address,
//		input  Clk,
//		output logic [23:0] data_Out
//);
//
//	logic [23:0] idle [1023:0];
//
//	initial
//	begin
//		$readmemh("sprite_bytes/sprite_27.txt", idle);
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
//module enemyWalkEast(
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
//	$readmemh("sprite_bytes/sprite_24",ani1);
//	$readmemh("sprite_bytes/sprite_25",ani2);
//end 
//always_ff @ (posedge Clk) begin
//	walk1 <= ani1[read_address1];
//	walk2 <= ani2[read_address1];
//end
//
//
//endmodule
//
//module spriteEnemyIdleWest(
//		input [18:0] read_address,
//		input  Clk,
//		output logic [23:0] data_Out
//);
//
//	logic [23:0] idle [1023:0];
//
//	initial
//	begin
//		$readmemh("sprite_bytes/sprite_23.txt", idle);
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
//module enemyWalkWest(
//	input [18:0] read_address1,
//	input Clk,
//	output logic [23:0] walk1, walk2
//);
//
//initial 
//begin
//	$readmemh("sprite_bytes/sprite_20",ani1);
//	$readmemh("sprite_bytes/sprite_21",ani2);
//end 
//always_ff @ (posedge Clk) begin
//	walk1 <= ani1[read_address1];
//	walk2 <= ani2[read_address1];
//end
//
//endmodule 