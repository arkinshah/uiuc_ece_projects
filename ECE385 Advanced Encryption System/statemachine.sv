/*

outputS FOR AES INTERFACE

output logic CLK,

// Avalon Reset output
output logic RESET,

// Avalon-MM Slave Signals
output  logic AVL_READ,					// Avalon-MM Read
output  logic AVL_WRITE,					// Avalon-MM Write
output  logic AVL_CS,						// Avalon-MM Chip Select
output  logic [3:0] AVL_BYTE_EN,		// Avalon-MM Byte Enable
output  logic [3:0] AVL_ADDR,			// Avalon-MM Address
output  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
output logic [31:0] EXPORT_DATA		// Exported Conduit Signal to LEDs
*/



//***************************************************************************************//

module FSM(input logic CLK,
 input logic RST,
 input logic AES_START,
 output logic AES_DONE,
 output logic [3:0] round;
 output logic [1:0] REGMUX,
 output logic [1:0] MIXCOLMUX
);

//remember to change AES_START eventually

enum logic [4:0] {START, /*RESET,*/ ADDROUNDKEY_0, INVSHIFTROWS_0, INVSUBBYTES_0, INVSUBBYTES_1, ADDROUNDKEY_1,
                  INVMIXCOLS0, INVMIXCOLS1, INVMIXCOLS2, INVMIXCOLS3, INVMIXCOLS4,
                  INVMIXCOLS5, INVMIXCOLS6, INVMIXCOLS7, INVMIXCOLS8, /*INVMIXCOLS9,*/
                  INVMIXCOLS_BUF1, INVMIXCOLS_BUF2, INVMIXCOLS_BUF3,
                  INVMIXCOLS_BUF_1, INVMIXCOLS_BUF_2, INVMIXCOLS_BUF_3,
                  INVSHIFTROWS_1, INVSUBBYTES_2, INVSUBBYTES_3, ADDROUNDKEY_2, DONE} state, next_state;

                  // ALLOWS 32 STATES (5 remain)

logic [3:0] counter;
assign counter = 4'd0;

/////////////// DEFAULT RESET STATES //////////////////

always_ff @ (posedge Clk)
begin
  if (RST)
    state <= START;
  else
    state <= next_state;
end


//////////////////// STATE TRANSITIONS ///////////////////////////////

always_comb
begin

  next_state = state; //default

  unique case(state)

    START: begin
      if(AES_START) next_state = ADDROUNDKEY_0;
      else next_state = START;
    end

    ADDROUNDKEY_0: next_state = INVSHIFTROWS_0;

    INVSHIFTROWS_0: next_state = INVSUBBYTES_0;

    INVSUBBYTES_0: next_state = INVSUBBYTES_1;

    INVSUBBYTES_1: next_state = ADDROUNDKEY_1;

    ADDROUNDKEY_1: begin

      if(counter==4'd0) begin
        next_state = INVMIXCOLS0;
        round <= counter;
      end

      else if(counter==4'd1) begin
        next_state = INVMIXCOLS1;
        round <= counter;
      end

      else if(counter==4'd2) begin
        next_state = INVMIXCOLS2;
        round <= counter;
      end

      else if(counter==4'd3) begin
        next_state = INVMIXCOLS3;
        round <= counter;
      end

      else if(counter==4'd4) begin
        next_state = INVMIXCOLS4;
        round <= counter;
      end

      else if(counter==4'd5) begin
        next_state = INVMIXCOLS5;
        round <= counter;
      end

      else if(counter==4'd6) begin
        next_state = INVMIXCOLS6;
        round <= counter;
      end

      else if(counter==4'd7) begin
        next_state = INVMIXCOLS7;
        round <= counter;
      end

      else if(counter==4'd8) begin
        next_state = INVMIXCOLS8;
        round <= counter;
      end

/*
      else if(counter==4'd9) begin
        next_state = INVMIXCOLS9;
        round <= counter;
      end
*/

    end

    INVMIXCOLS0: begin
    counter <= 4'd1 + counter;
    next_state = INVMIXCOLS_BUF1;
    end

    INVMIXCOLS1: begin
    counter <= 4'd1 + counter;
    next_state = INVMIXCOLS_BUF1;
    end

    INVMIXCOLS2: begin
    counter <= 4'd1 + counter;
    next_state = INVMIXCOLS_BUF1;
    end

    INVMIXCOLS3: begin
    counter <= 4'd1 + counter;
    next_state = INVSHIFTROWS_0;
    end

    INVMIXCOLS4: begin
    counter <= 4'd1 + counter;
    next_state = INVMIXCOLS_BUF1;
    end

    INVMIXCOLS5: begin
    counter <= 4'd1 + counter;
    next_state = INVMIXCOLS_BUF1;
    end

    INVMIXCOLS6: begin
    counter <= 4'd1 + counter;
    next_state = INVMIXCOLS_BUF1;
    end

    INVMIXCOLS7: begin
    counter <= 4'd1 + counter;
    next_state = INVMIXCOLS_BUF1;
    end

    INVMIXCOLS8: begin
    counter <= 4'd1 + counter;
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
    INVMIXCOLS_BUF3: next_state = INVSHIFTROWS_0;

    INVMIXCOLS_BUF_1: next_state = INVMIXCOLS_BUF_2;
    INVMIXCOLS_BUF_2: next_state = INVMIXCOLS_BUF_3;
    INVMIXCOLS_BUF_3: next_state = INVSHIFTROWS_1;


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
    AES_DONE = 1'b0;
    end

    DONE:
    begin
      AES_DONE = 1'b1;
      REGMUX = 2'bXX;
      MIXCOLMUX = 2'bXX;
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
      AES_DONE = 1'b0;
      REGMUX = 2'b00;
      MIXCOLMUX = 2'bXX; // might have to add rounds output as a control signal. BIG PROBLEM.
    end

    INVSHIFTROWS_0:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b01;
      MIXCOLMUX = 2'bXX;
    end

    INVSUBBYTES_0:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b11;
      MIXCOLMUX = 2'bXX;
    end

    INVSUBBYTES_1:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'bXX;
      MIXCOLMUX = 2'bXX;
    end

    ADDROUNDKEY_1:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b00;
      MIXCOLMUX = 2'bXX;
    end

    INVMIXCOLS0:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
    end

    INVMIXCOLS1:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
    end

    INVMIXCOLS2:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
    end

    INVMIXCOLS3:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
    end

    INVMIXCOLS4:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
    end

    INVMIXCOLS5:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
    end

    INVMIXCOLS6:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
    end

    INVMIXCOLS7:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
    end

    INVMIXCOLS8:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
    end

    INVMIXCOLS9:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'b0;
    end

    INVMIXCOLS_BUF1:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'd1;
    end

    INVMIXCOLS_BUF2:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'd2;
    end

    INVMIXCOLS_BUF3:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'd3;
    end

    INVMIXCOLS_BUF_1:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'd1;
    end

    INVMIXCOLS_BUF_2:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'd2;
    end

    INVMIXCOLS_BUF_3:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b10;
      MIXCOLMUX = 2'd3;
    end

    INVSHIFTROWS_1:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b01;
      MIXCOLMUX = 2'bXX;
    end

    INVSUBBYTES_2:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b11;
      MIXCOLMUX = 2'bXX;
    end

    INVSUBBYTES_3:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'bXX;
      MIXCOLMUX = 2'bXX;
    end

    ADDROUNDKEY_2:
    begin
      AES_DONE = 1'b0;
      REGMUX = 2'b00;
      MIXCOLMUX = 2'bXX;
    end


  endcase


end


endmodule





























/*
////////////// reset all registers ///////////////
always @ (posedge CLOCK)
begin

  if (RESET)
      state <= RST;
  else
      state <= next_state;

end

////////////// SET DEFAULT SIGNALS /////////////
always_comb
begin
  RESET_avalon,
  AVL_READ = 1'b0;				// Avalon-MM Read
  AVL_WRITE = 1'b0;					// Avalon-MM Write
  AVL_CS = 1'b0;					// Avalon-MM Chip Select
  AVL_BYTE_EN = 4'b1111;		// Avalon-MM Byte Enable
  AVL_ADDR = 4'd0;		// Avalon-MM Address
  AES_START = 1'b0;

//////////// copy shit into registers ////////////////

  case(state)
    copyk0: next_state = copyk1;
    copyk1: next_state = copyk2;
    copyk2: next_state = copyk3;
    copyk3: next_state = copyen0;
    copyen0: next_state = copyen1;
    copyen1: next_state = copyen2;
    copyen2: next_state = copyen3;
    copyen3: next_state = copydec0;
    copydec0: next_state = copydec1;
    copydec1: next_state = copydec2;
    copydec2: next_state = copydec3;
    copydec3: next_state = waitaftercopying;
  endcase

end

///////////// state descriptions /////////////////
always_comb
begin

  unique case(state)

    RST: RESET_avalon = 1'b1;

    copyk0:
    begin
    AVL_WRITE = 1'b1;					// Avalon-MM Write
    AVL_CS = 1'b1;				// Avalon-MM Chip Select
    //AVL_BYTE_EN = 4'b1111;	// Avalon-MM Byte Enable
    AVL_ADDR = 4'd0;			// Avalon-MM Address
    end

    copyk1:
    begin
    AVL_WRITE = 1'b1;					// Avalon-MM Write
    AVL_CS = 1'b1;				// Avalon-MM Chip Select
    //AVL_BYTE_EN = 4'b1111;	// Avalon-MM Byte Enable
    AVL_ADDR = 4'd1;			// Avalon-MM Address
    end

    copyk2:
    begin
    AVL_WRITE = 1'b1;					// Avalon-MM Write
    AVL_CS = 1'b1;				// Avalon-MM Chip Select
    //AVL_BYTE_EN = 4'b1111;	// Avalon-MM Byte Enable
    AVL_ADDR = 4'd2;			// Avalon-MM Address
    end

    copyk3:
    begin
    AVL_WRITE = 1'b1;					// Avalon-MM Write
    AVL_CS = 1'b1;				// Avalon-MM Chip Select
    //AVL_BYTE_EN = 4'b1111;	// Avalon-MM Byte Enable
    AVL_ADDR = 4'd3;			// Avalon-MM Address
    end

    copyen0:
    begin
    AVL_WRITE = 1'b1;					// Avalon-MM Write
    AVL_CS = 1'b1;				// Avalon-MM Chip Select
    //AVL_BYTE_EN = 4'b1111;	// Avalon-MM Byte Enable
    AVL_ADDR = 4'd4;			// Avalon-MM Address
    end

    copyen1:
    begin
    AVL_WRITE = 1'b1;					// Avalon-MM Write
    AVL_CS = 1'b1;				// Avalon-MM Chip Select
    //AVL_BYTE_EN = 4'b1111;	// Avalon-MM Byte Enable
    AVL_ADDR = 4'd5;			// Avalon-MM Address
    end

    copyen2:
    begin
    AVL_WRITE = 1'b1;					// Avalon-MM Write
    AVL_CS = 1'b1;				// Avalon-MM Chip Select
    //AVL_BYTE_EN = 4'b1111;	// Avalon-MM Byte Enable
    AVL_ADDR = 4'd6;			// Avalon-MM Address
    end

    copyen3:
    begin
    AVL_WRITE = 1'b1;					// Avalon-MM Write
    AVL_CS = 1'b1;				// Avalon-MM Chip Select
    //AVL_BYTE_EN = 4'b1111;	// Avalon-MM Byte Enable
    AVL_ADDR = 4'd7;			// Avalon-MM Address
    end

    copydec0:
    begin
    AVL_WRITE = 1'b1;					// Avalon-MM Write
    AVL_CS = 1'b1;				// Avalon-MM Chip Select
    //AVL_BYTE_EN = 4'b1111;	// Avalon-MM Byte Enable
    AVL_ADDR = 4'd8;			// Avalon-MM Address
    end

    copydec1:
    begin
    AVL_WRITE = 1'b1;					// Avalon-MM Write
    AVL_CS = 1'b1;				// Avalon-MM Chip Select
    //AVL_BYTE_EN = 4'b1111;	// Avalon-MM Byte Enable
    AVL_ADDR = 4'd9;			// Avalon-MM Address
    end

    copydec2:
    begin
    AVL_WRITE = 1'b1;					// Avalon-MM Write
    AVL_CS = 1'b1;				// Avalon-MM Chip Select
    //AVL_BYTE_EN = 4'b1111;	// Avalon-MM Byte Enable
    AVL_ADDR = 4'd10;			// Avalon-MM Address
    end

    copydec3:
    begin
    AVL_WRITE = 1'b1;					// Avalon-MM Write
    AVL_CS = 1'b1;				// Avalon-MM Chip Select
    //AVL_BYTE_EN = 4'b1111;	// Avalon-MM Byte Enable
    AVL_ADDR = 4'd11;			// Avalon-MM Address
    end

  endcase


end

*/
