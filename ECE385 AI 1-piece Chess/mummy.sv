module  mummy ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,			 // The clock indicating a new frame (~60Hz)
									  Run,
									  go, go2,
					input	[3:0]	  button,
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
               output logic  is_ball,            // Whether current pixel belongs to ball or background
					output logic  turn1done, turn2done
              );

    parameter [9:0] Ball_X_Center = 10'd141;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center = 10'd61;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min = 10'd116;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max = 10'd523;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min = 10'd36;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max = 10'd443;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step = 10'd51;      // Step size on the X axis changed from 1 to 10
    parameter [9:0] Ball_Y_Step = 10'd51;      // Step size on the Y axis
    parameter [9:0] Ball_Size = 10'd11;        // Ball size

    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
	 logic boundary, wall;
   logic [1:0] counterin, counter;

    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end


    // Update registers
    always_ff @ (posedge Clk)
    begin
        if (Reset|Run)
        begin
            Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Center;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0;
            counter <= 2'd0;
        end
        else
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
            counter <= counterin;
        end
    end
    //////// Do not modify the always_ff blocks. ////////

    // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
        Ball_X_Pos_in = Ball_X_Pos;
        Ball_Y_Pos_in = Ball_Y_Pos;
        Ball_X_Motion_in = Ball_X_Motion;
        Ball_Y_Motion_in = Ball_Y_Motion; //change from Ball_?_Motion;
		  boundary = 1'b0;
      wall = 1'b0;
      counterin = counter;

      if(go && counter==2'd1)
      begin
        turn1done = 1'b1;
        turn2done = 1'b0;
      end

      else if(go2 && counter==2'd2)
      begin
        turn1done = 1'b1;
        turn2done = 1'b1;
      end

      else
      begin
        turn1done = 1'b0;
        turn2done = 1'b0;
      end

        // Update position and motion only at rising edge of frame clock
        if ( frame_clk_rising_edge && (go|go2) )
        begin
            // Be careful when using comparators with "logic" datatype because compiler treats
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min
            // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.

				case(button)


				4'b1000: // w = Up
				begin
					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
					Ball_Y_Motion_in = ~(Ball_Y_Step) + 1'b1; // 2's complement up
					counterin = counter + 2'd1;
				end

				4'b0100: // a = left
				begin
					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
					Ball_X_Motion_in = ~(Ball_X_Step) + 1'b1; // 2's complement left
          counterin = counter + 2'd1;

				end

				4'b0001: // s = down
				begin
					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
					Ball_Y_Motion_in = Ball_Y_Step; // move down
          counterin = counter + 2'd1;

				end

				4'b0010: // d = right;
				begin
					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
					Ball_X_Motion_in = Ball_X_Step; // move right
          counterin = counter + 2'd1;

				end

				default:
					begin
					Ball_Y_Motion_in = 10'd0;
					Ball_X_Motion_in = 10'd0;
					end

			endcase

			 // Update the ball's position with its motion
            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;


            if( (Ball_Y_Pos_in + Ball_Size) >= Ball_Y_Max) 	// Ball is at the bottom edge, BOUNCE!
					 begin
                boundary = 1'b1;
					 end

            else if ( (Ball_Y_Pos_in - Ball_Size) <= Ball_Y_Min )  // Ball is at the top edge, BOUNCE!
						begin
						boundary = 1'b1;
						end
				else

				if( (Ball_X_Pos_in + Ball_Size) >= Ball_X_Max)  // Ball is at the right edge, BOUNCE!
					 begin
                boundary = 1'b1;
					 end
            else if ( (Ball_X_Pos_in - Ball_Size) <= Ball_X_Min)  // Ball is at the left edge, BOUNCE!   Don't move!!! //add step?
					 begin
                boundary = 1'b1;
					 end

           // WALL 1 TOP Horizontal LINE
           else if(Ball_X_Pos_in>=(10'd167-Ball_Size) && Ball_X_Pos_in<=(10'd268+Ball_Size) && Ball_Y_Pos_in>=(10'd87-Ball_Size) && Ball_Y_Pos_in<=(10'd137+Ball_Size))
           begin
                boundary = 1'b1;
                counterin = counter + 2'd1;
					 end

           // WALL 1 VERTICAL LINE
           else if(Ball_X_Pos_in>=(10'd167-Ball_Size) && Ball_X_Pos_in<=(10'd217+Ball_Size) && Ball_Y_Pos_in>=(10'd87-Ball_Size) && Ball_Y_Pos_in<=(10'd188+Ball_Size))
           begin
                wall = 1'b1;
					 end

           // WALL 2
           else if(Ball_X_Pos_in>=(10'd218-Ball_Size) && Ball_X_Pos_in<=(10'd319+Ball_Size) && Ball_Y_Pos_in>=(10'd240-Ball_Size) && Ball_Y_Pos_in<=(10'd290+Ball_Size))
           begin
                wall = 1'b1;
					 end

           // WALL 3
           else if(Ball_X_Pos_in>=(10'd167-Ball_Size) && Ball_X_Pos_in<=(10'd217+Ball_Size) && Ball_Y_Pos_in>=(10'd342-Ball_Size) && Ball_Y_Pos_in<=(10'd392+Ball_Size))
           begin
                wall = 1'b1;
					 end

           // WALL 4
           else if(Ball_X_Pos_in>=(10'd422-Ball_Size) && Ball_X_Pos_in<=(10'd523+Ball_Size) && Ball_Y_Pos_in>=(10'd138-Ball_Size) && Ball_Y_Pos_in<=(10'd188+Ball_Size))
           begin
                wall = 1'b1;
					 end

           // WALL 5
           else if(Ball_X_Pos_in>=(10'd422-Ball_Size) && Ball_X_Pos_in<=(10'd472+Ball_Size) && Ball_Y_Pos_in>=(10'd240-Ball_Size) && Ball_Y_Pos_in<=(10'd290+Ball_Size))
           begin
                wall = 1'b1;
					 end

				if(boundary)
				begin
				Ball_X_Pos_in = Ball_X_Pos;
        Ball_Y_Pos_in = Ball_Y_Pos;
        counterin = counter;
				end

        else if(wall)
				begin
				Ball_X_Pos_in = Ball_X_Pos;
        Ball_Y_Pos_in = Ball_Y_Pos;
				end




        end /*****************************  END OF IF-CLK STATEMENT  *******************************************************/



        /*********************************  END OF ALWAYS COMB BLOCK  *****************************************************/
    end

    // Compute whether the pixel corresponds to ball or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int DistX, DistY, Size;
    assign DistX = DrawX - Ball_X_Pos;
    assign DistY = DrawY - Ball_Y_Pos;
    assign Size = Ball_Size;
    always_comb begin
        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) )
            is_ball = 1'b1;
        else
            is_ball = 1'b0;
        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
    end

endmodule






module timer(input logic Clk, Reset, enable,
              input logic [3:0] keyin,
              output logic [3:0] keyout,
              output logic ticktock);

logic [25:0] counterin, counter;
logic [4:0] secondsin, seconds;

always_ff @(posedge Clk)
begin

  if(Reset)
  begin
    counter <= 26'd0;
    seconds <= 5'd0;
  end

  else
  begin
    counter <= counterin;
    seconds <= secondsin;
  end

end

always_ff @(posedge Clk && enable)
begin
  counterin = counterin + 26'd1;
end

always_comb
begin

  ticktock = 1'b0;
  keyout = 4'b0;
  secondsin = seconds;

  if(counter == 26'd50000000)
  begin
    secondsin = seconds + 5'd1;
  end

  if(seconds==5'd1)
  begin
  ticktock = 1'b1;
  keyout = keyin;
  end

end

endmodule