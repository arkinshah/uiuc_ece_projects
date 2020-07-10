module FSM(
input logic Clk,
input logic Reset,
input logic Run,
input delayachieved,


input logic playdon, mumdon1, mumdon2, VS, //Tell the FSM the player has finished inputing a move //Tell the FSM the enemy has made a move
// 1 is enemy turn, 0 is player turn

//input logic win,
//input logic loss,
//input logic cont,


output logic playerSignal,
output logic mummySignal, mummySignal2,
output logic startcounting


//output logic opening,
//output logic gameover, //output signals to stop the game
//output logic winner



);

//check if Run is iinplimented
enum logic [3:0] {START, Buf_Player, PlayerTurn, Count1, EnemyTurn1, Count2, EnemyTurn2, Count3, PositionCheck ,Win, Loss} state, nextstate;


/*
Player makes move on


x3fgxxfgk



*/

always_ff @ (posedge Clk)
begin

if (Reset) begin
state <= START;
//add reset signals to reset player and mummy positions?
end
else
state <= nextstate;

end

///State Transitions

always_comb
begin

nextstate = state;

//turn = 1'b0; //default is player. Is turn determined in the FSM or outside? The way I determined it has it dtermined outside FSM
playerSignal = 1'b0;
mummySignal = 1'b0;
mummySignal2 = 1'b0;

//opening = 1'b0;
//gameover = 1'b0;
//winner = 1'b0;

unique case (state)

	START:
	if (Run)
		nextstate = PlayerTurn;
	else
		nextstate = START;

		Buf_Player:
		 if (~delayachieved)
				nextstate = Buf_Player;
		 else
			 nextstate = PlayerTurn;

	PlayerTurn:
	 if (~playdon)
			nextstate = PlayerTurn;
	 else
		 nextstate = Count1;

	Count1:
	 if (~delayachieved)
			nextstate = Count1;
	 else
		 nextstate = EnemyTurn1_0;

	EnemyTurn1:
	 if (~mumdon1)
			nextstate = EnemyTurn1;
	  else
			nextstate = Count2;

	Count2:
	 if (~delayachieved)
			nextstate = Count2;
	  else
			nextstate = EnemyTurn2;

	EnemyTurn2:
		if (~mumdon2)
			nextstate = EnemyTurn2;
		else
			nextstate = Count3;
			//nextstate = PositionCheck;

	Count3:
		if (~delayachieved)
			nextstate = Count3;
		else
			nextstate = Buf_Player;

//	PositionCheck:
//		if (win)
//			nextstate = Win;
//		else if (loss)
//			nextstate = Loss;
//		else if (cont)
//			nextstate = PlayerTurn;
//
//	Win:
//		if (Run)
//			nextstate = START;
//		else nextstate = Win;
//			//want to play again?
//	Loss:
//		if (Run)
//			nextstate = START;
//		else nextstate = Loss;

	default : ;


endcase

case (state)

START:
begin
playerSignal = 1'b0;
mummySignal = 1'b0;
mummySignal2 = 1'b0;
startcounting = 1'b0;
//opening = 1'b1;
end

Buf_Player:
begin
playerSignal = 1'b1;
mummySignal = 1'b0;
mummySignal2 = 1'b0;
startcounting = 1'b1;
end

PlayerTurn:
begin
playerSignal = 1'b1;
mummySignal = 1'b0;
mummySignal2 = 1'b0;
startcounting = 1'b0;
end

Count1:
begin
playerSignal = 1'b0;
mummySignal = 1'b0;
mummySignal2 = 1'b0;
startcounting = 1'b1;
end

EnemyTurn1:
begin
playerSignal = 1'b0;
mummySignal = 1'b1;
mummySignal2 = 1'b0;
startcounting = 1'b0;
end

Count2:
begin
playerSignal = 1'b0;
mummySignal = 1'b0;
mummySignal2 = 1'b0;
startcounting = 1'b1;
end

EnemyTurn2:
begin
playerSignal = 1'b0;
mummySignal = 1'b0;
mummySignal2 = 1'b1;
startcounting = 1'b0;
end

Count3:
begin
playerSignal = 1'b0;
mummySignal = 1'b0;
mummySignal2 = 1'b0;
startcounting = 1'b1;
end



//PositionCheck: ;
//
//Win:
//begin
//winner = 1'b1;
//end
//
//
//Loss:
//begin
//gameover = 1'b1;
//end

default: ;

endcase

end

endmodule
