module FSM(input logic CLK,
 input logic RST,
 input logic getAES_START,
 output logic getAES_DONE,
 output logic [3:0] round,
 output logic [1:0] REGMUX,
 output logic [1:0] MIXCOLMUX,
 
 //need to make:
 output logic valMux
 
);

//remember to change AES_START eventually

enum logic [4:0] {START, /*RESET,*/ ADDROUNDKEY_0, INVSHIFTROWS_0, INVSUBBYTES_0, INVSUBBYTES_1, ADDROUNDKEY_1,
                  INVMIXCOLS0, INVMIXCOLS1, INVMIXCOLS2, INVMIXCOLS3, INVMIXCOLS4,
                  INVMIXCOLS5, INVMIXCOLS6, INVMIXCOLS7, INVMIXCOLS8, /*INVMIXCOLS9,*/
                  INVMIXCOLS_BUF1, INVMIXCOLS_BUF2, INVMIXCOLS_BUF3, INVMIXCOLS_compile,
                  INVMIXCOLS_BUF_1, INVMIXCOLS_BUF_2, INVMIXCOLS_BUF_3, INVMIXCOLS_compile_1,
                  INVSHIFTROWS_1, INVSUBBYTES_2, INVSUBBYTES_3, ADDROUNDKEY_2, DONE} state, next_state;

                  // ALLOWS 32 STATES (4 remain)

logic [3:0] counter;
//assign counter = 4'd0;

/////////////// DEFAULT RESET STATES //////////////////

always_ff @ (posedge CLK)
begin

counter = 4'd1 + counter;

  if (RST) begin
    state <= START;
	 counter = 4'd0;
	end 
  else
    state <= next_state;
end


//////////////////// STATE TRANSITIONS ///////////////////////////////

always_comb
begin

  next_state = state; //default
  
  getAES_DONE = 1'b0;
  round = 4'b0;
  REGMUX = 2'b0;
  MIXCOLMUX = 2'b0;
  valMux = 1'b0;
  
  

  unique case (state)

    START: begin
      if(getAES_START) next_state = ADDROUNDKEY_0;
      else next_state = START;
		end

    ADDROUNDKEY_0: next_state = INVSHIFTROWS_0;


    INVSHIFTROWS_0: next_state = INVSUBBYTES_0;

    INVSUBBYTES_0: next_state = INVSUBBYTES_1;

    INVSUBBYTES_1:
	 next_state = ADDROUNDKEY_1;

    ADDROUNDKEY_1: begin

      if(counter==4'd0) begin
        next_state = INVMIXCOLS0;
        round = counter;
							end

      else if(counter==4'd1) begin
        next_state = INVMIXCOLS1;
        round = counter;
      end

      else if(counter==4'd2) begin
        next_state = INVMIXCOLS2;
        round = counter;
      end

      else if(counter==4'd3) begin
        next_state = INVMIXCOLS3;
        round = counter;
      end

      else if(counter==4'd4) begin
        next_state = INVMIXCOLS4;
        round = counter;
      end

      else if(counter==4'd5) begin
        next_state = INVMIXCOLS5;
        round = counter;
      end

      else if(counter==4'd6) begin
        next_state = INVMIXCOLS6;
        round = counter;
      end

      else if(counter==4'd7) begin
        next_state = INVMIXCOLS7;
        round = counter;
      end

      else if(counter==4'd8) begin
        next_state = INVMIXCOLS8;
        round = counter;
      end

/*
      else if(counter==4'd9) begin
        next_state = INVMIXCOLS9;
        round <= counter;
      end
*/

    end

    INVMIXCOLS0: begin
    //counter <= 4'd1 + counter;
    next_state = INVMIXCOLS_BUF1;
    end

    INVMIXCOLS1: begin
    //counter <= 4'd1 + counter;
    next_state = INVMIXCOLS_BUF1;
    end

    INVMIXCOLS2: begin
    //counter <= 4'd1 + counter;
    next_state = INVMIXCOLS_BUF1;
    end

    INVMIXCOLS3: begin
    //counter <= 4'd1 + counter;
    next_state = INVSHIFTROWS_0;
    end

    INVMIXCOLS4: begin
    //counter <= 4'd1 + counter;
    next_state = INVMIXCOLS_BUF1;
    end

    INVMIXCOLS5: begin
    //counter <= 4'd1 + counter;
    next_state = INVMIXCOLS_BUF1;
    end

    INVMIXCOLS6: begin
    //counter <= 4'd1 + counter;
    next_state = INVMIXCOLS_BUF1;
    end

    INVMIXCOLS7: begin
    //counter <= 4'd1 + counter;
    next_state = INVMIXCOLS_BUF1;
    end

    INVMIXCOLS8: begin
    //counter <= 4'd1 + counter;
    next_state = INVMIXCOLS_BUF_1;
    end

/*
    INVMIXCOLS9: begin
    counter <= 4'd1 + counter;
    next_state = INVMIXCOLS_BUF_1;
    end
*/

    INVMIXCOLS_BUF1: next_state = INVMIXCOLS_BUF2;
    INVMIXCOLS_BUF2: next_state = INVMIXCOLS_BUF3;
    INVMIXCOLS_BUF3: next_state = INVMIXCOLS_compile;
	 INVMIXCOLS_compile: next_state = INVSHIFTROWS_0;

    INVMIXCOLS_BUF_1: next_state = INVMIXCOLS_BUF_2;
    INVMIXCOLS_BUF_2: next_state = INVMIXCOLS_BUF_3;
    INVMIXCOLS_BUF_3: next_state = INVMIXCOLS_compile_1;
	 INVMIXCOLS_compile_1: next_state = INVSHIFTROWS_1;
	 
    INVSHIFTROWS_1: next_state = INVSUBBYTES_2;

    INVSUBBYTES_2: next_state = INVSUBBYTES_3;

    INVSUBBYTES_3: next_state = ADDROUNDKEY_2;

    ADDROUNDKEY_2: next_state = DONE;

    DONE: next_state = START;

    default next_state = START;

  endcase


///////////////// STATE DESCRIPTIONS AND CONTROL SIGNALS ///////////////////
/////// STILL THE SAME always_comb BLOCK /////////

  case(state)

    START: begin
    getAES_DONE = 1'b0;
    end

    DONE:
    begin
      getAES_DONE = 1'b1;
      REGMUX = 2'bXX;
      MIXCOLMUX = 2'bXX;
		valMux = 1'b0;
    end

/*
    RESET:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'bXX;
      MIXCOLMUX = 2'bXX;
    end
*/

    ADDROUNDKEY_0:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b00;
      MIXCOLMUX = 2'bXX; // might have to add rounds output as a control signal. BIG PROBLEM.
		valMux = 1'b1;
    end

    INVSHIFTROWS_0:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b01;
      MIXCOLMUX = 2'bXX;
		valMux = 1'b0;
    end

    INVSUBBYTES_0:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b11;
      MIXCOLMUX = 2'bXX;
		valMux = 1'b0;
    end

    INVSUBBYTES_1:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'bXX;
      MIXCOLMUX = 2'bXX;
		valMux = 1'b0;
    end

    ADDROUNDKEY_1:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b00;
      MIXCOLMUX = 2'bXX;
		valMux = 1'b0;
    end

    INVMIXCOLS0:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
		valMux = 1'b0;
    end

    INVMIXCOLS1:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
		valMux = 1'b0;
    end

    INVMIXCOLS2:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
		valMux = 1'b0;
    end

    INVMIXCOLS3:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
		valMux = 1'b0;
    end

    INVMIXCOLS4:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
		valMux = 1'b0;
    end

    INVMIXCOLS5:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
		valMux = 1'b0;
    end

    INVMIXCOLS6:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
		valMux = 1'b0;
    end

    INVMIXCOLS7:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
		valMux = 1'b0;
    end

    INVMIXCOLS8:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
		valMux = 1'b0;
    end

  /*  INVMIXCOLS9:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
    end
*/
    INVMIXCOLS_BUF1:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'd1;
		valMux = 1'b0;
    end

    INVMIXCOLS_BUF2:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'd2;
		valMux = 1'b0;
    end

    INVMIXCOLS_BUF3:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'd3;
		valMux = 1'b0;
    end
	 
	 INVMIXCOLS_compile:
	 begin
	 getAES_DONE = 1'b0;
	 valMux = 1'b0;
	 REGMUX = 2'b10;
	 MIXCOLMUX = 2'bXX;
	 end

    INVMIXCOLS_BUF_1:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'd1;
		valMux = 1'b0;
    end

    INVMIXCOLS_BUF_2:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'd2;
		valMux = 1'b0;
    end

    INVMIXCOLS_BUF_3:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'd3;
		valMux = 1'b0;
    end
	 
	 INVMIXCOLS_compile_1:
	 begin
	 getAES_DONE = 1'b0;
	 valMux = 1'b0;
	 REGMUX = 2'b10;
	 MIXCOLMUX = 2'bXX;
	 end

    INVSHIFTROWS_1:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b01;
      MIXCOLMUX = 2'bXX;
		valMux = 1'b0;
    end

    INVSUBBYTES_2:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b11;
      MIXCOLMUX = 2'bXX;
		valMux = 1'b0;
    end

    INVSUBBYTES_3:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'bXX;
      MIXCOLMUX = 2'bXX;
		valMux = 1'b0;
    end

    ADDROUNDKEY_2:
    begin
      getAES_DONE = 1'b0;
      REGMUX = 2'b00;
      MIXCOLMUX = 2'bXX;
		valMux = 1'b0;
    end


  endcase


end


endmodule

