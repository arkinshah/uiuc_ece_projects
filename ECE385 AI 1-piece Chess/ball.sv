//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  12-08-2017                               --
//    Spring 2018 Distribution                                           --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------
//when white ball moves, mummy moves at well (Check FSM)

module  ball ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
									  Run,
                             frame_clk,			 // The clock indicating a new frame (~60Hz)
									  go,
					input	[3:0]	  button,
               input [9:0]   DrawX, DrawY, xcent, ycent,      // Current pixel coordinates
               output logic  is_ball, turndone             // Whether current pixel belongs to ball or background
              );
    
    parameter [9:0] Ball_X_Min = 10'd141;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max = 10'd498;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min = 10'd61;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max = 10'd418;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step = 10'd51;      // Step size on the X axis changed from 1 to 10
    parameter [9:0] Ball_Y_Step = 10'd51;      // Step size on the Y axis
    parameter [9:0] Ball_Size = 10'd11;        // Ball size
    
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
	 //logic counter, counterin;
	 logic flag;
    
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
        if (Reset | Run)
        begin
            Ball_X_Pos <= xcent;
            Ball_Y_Pos <= ycent;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0;
				//counter <= 1'b0;
        end
        else
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in; 
            Ball_Y_Motion <= Ball_Y_Motion_in;
				//counter <= counterin;
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
		  //counterin = counter;
		  //turndone = 1'b0;
        flag = 1'b0;
		  
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge && go)
        begin
            // Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
            // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
				
//				if( (Ball_Y_Pos + Ball_Size + Ball_Y_Step >= Ball_Y_Max) && (Ball_X_Pos <= Ball_X_Min + Ball_Size + Ball_X_Step) && ((button==4'b0100)|(button==4'b0001)))
//				// Ball is at the bottom-left edge, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 end
//					 
//				else if( (Ball_Y_Pos + Ball_Size + Ball_Y_Step >= Ball_Y_Max) && (Ball_X_Pos + Ball_Size + Ball_X_Step >= Ball_X_Max) && ((button==4'b0010)|(button==4'b0001)))
//				// Ball is at the bottom-right edge, don't allow movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 end	 
//				
//            else if ( (Ball_Y_Pos + Ball_Size + Ball_Y_Step >= Ball_Y_Max) && (button==4'b0001)) 	// Ball is at the bottom edge, do nothing
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 end
//					 
//            else if ( (Ball_Y_Pos <= Ball_Y_Min + Ball_Size + Ball_Y_Step) && (button==4'b1000))  // Ball is at the top edge, no movement!
//						begin
//						Ball_Y_Motion_in  = 10'd0; 
//						Ball_X_Motion_in = 10'd0;
//						end
//						
//				else if ((Ball_Y_Pos <= Ball_Y_Min + Ball_Size + Ball_Y_Step) && (Ball_X_Pos <= Ball_X_Min + Ball_Size + Ball_X_Step) && ((button==4'b0100)|(button==4'b1000)))  
//				// Ball is at the top-left edge, no movement!
//						begin
//						Ball_Y_Motion_in  = 10'd0; 
//						Ball_X_Motion_in = 10'd0;
//						end
//				
//				else if ((Ball_Y_Pos <= Ball_Y_Min + Ball_Size + Ball_Y_Step) && (Ball_X_Pos + Ball_Size + Ball_X_Step >= Ball_X_Max) && ((button==4'b0010)|(button==4'b1000)))  
//				// Ball is at the top-right edge, no movement!
//						begin
//						Ball_Y_Motion_in  = 10'd0;
//						Ball_X_Motion_in = 10'd0;
//						end	
//						
//				else	 
//				
//				if ( (Ball_X_Pos + Ball_Size + Ball_X_Step >= Ball_X_Max) && (button==4'b0010))  // Ball is at the right edge, BOUNCE!
//					 begin
//                Ball_X_Motion_in = 10'd0; // 2's complement. Changed from (~(Ball_X_Step) + 1'b1)
//					 Ball_Y_Motion_in = 10'd0;
//					 end
//            else if ( (Ball_X_Pos <= Ball_X_Min + Ball_Size + Ball_X_Step) && ((button==4'b0100) )  // Ball is at the left edge, no movement!
//					 begin
//                Ball_X_Motion_in = 10'd0;
//					 Ball_Y_Motion_in = 10'd0;
//					 end
					 
				/***** WALL CONDITIONS *****/	 

//            if( Ball_Y_Pos + Ball_Size + Ball_Y_Step >= Ball_Y_Max) 	// Ball is at the bottom edge, BOUNCE!
//					 begin
//                Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);//changed from (~(Ball_Y_Step) + 1'b1);// 2's complement.
//					 Ball_X_Motion_in = 10'd0;
//					 end
//					 
//            else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size + Ball_Y_Step)  // Ball is at the top edge, BOUNCE!
//						begin
//						Ball_Y_Motion_in  = Ball_Y_Step; // changed from Ball_Y_Step; //add 1?
//						Ball_X_Motion_in = 10'd0;
//						end
//				else	 
//				
//				if( Ball_X_Pos + Ball_Size + Ball_X_Step >= Ball_X_Max)  // Ball is at the right edge, BOUNCE!
//					 begin
//                Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1); // 2's complement. Changed from (~(Ball_X_Step) + 1'b1)
//					 Ball_Y_Motion_in = 10'd0;
//					 end
//            else if ( Ball_X_Pos <= Ball_X_Min + Ball_Size + Ball_X_Step)  // Ball is at the left edge, BOUNCE!   Don't move!!! //add step?
//					 begin
//                Ball_X_Motion_in = Ball_X_Step; //changed from Ball_X_Step
//					 Ball_Y_Motion_in = 10'd0;
//					 end

//				/*********************** DEALING WITH WALL 1*********************************************/
//				
//				else if (Ball_X_Pos >=10'd167 && Ball_X_Pos<=10'd268 && Ball_Y_Pos>=10'd36 && Ball_Y_Pos<= 10'd86 && button==4'b0001) 	
//				// Ball is trying to go down to wall 1 from the top, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end
//					 
//				else if (Ball_X_Pos >=10'd269 && Ball_X_Pos<=10'd319 && Ball_Y_Pos>=10'd87 && Ball_Y_Pos<= 10'd137 && button==4'b0100) 	
//				// Ball is trying to go left to wall 1 from the right-top, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end
//				
//				else if (Ball_X_Pos >=10'd218 && Ball_X_Pos<=10'd268 && Ball_Y_Pos>=10'd138 && Ball_Y_Pos<= 10'd188 && button==4'b0100) 	
//				// Ball is trying to go left to wall 1 from the right-bottom, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end	
//					 
//					 
//				else if (Ball_X_Pos >=10'd116 && Ball_X_Pos<=10'd166 && Ball_Y_Pos>=10'd87 && Ball_Y_Pos<= 10'd188 && button==4'b0010) 	
//				// Ball is trying to go right to wall 1 from the left-top, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end	
//					 
//				else if (Ball_X_Pos >=10'd167 && Ball_X_Pos<=10'd217 && Ball_Y_Pos>=10'd189 && Ball_Y_Pos<= 10'd239 && button==4'b1000) 	
//				// Ball is trying to go up to wall 1 from the bottom left, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end	
//					
//				else if (Ball_X_Pos >=10'd218 && Ball_X_Pos<=10'd268 && Ball_Y_Pos>=10'd138 && Ball_Y_Pos<= 10'd188 && button==4'b1000) 	
//				// Ball is trying to go up to wall 1 from the right-bottom, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end		
//					 
//				 
//					 
//				/*********************** DEALING WITH WALL 2 *********************************************/	 
//					
//				else if (Ball_X_Pos >=10'd218 && Ball_X_Pos<=10'd319 && Ball_Y_Pos>=10'd189 && Ball_Y_Pos<= 10'd239 && button==4'b0001) 	
//				// Ball is trying to go down to wall 2 from the top, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end	
//					 
//				else if (Ball_X_Pos >=10'd320 && Ball_X_Pos<=10'd370 && Ball_Y_Pos>=10'd240 && Ball_Y_Pos<= 10'd290 && button==4'b0100) 	
//				// Ball is trying to go left to wall 2, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end
//					 
//				else if (Ball_X_Pos >=10'd167 && Ball_X_Pos<=10'd217 && Ball_Y_Pos>=10'd240 && Ball_Y_Pos<= 10'd290 && button==4'b0010) 	
//				// Ball is trying to go right to wall 2, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end	
//				
//				else if (Ball_X_Pos >=10'd218 && Ball_X_Pos<=10'd319 && Ball_Y_Pos>=10'd291 && Ball_Y_Pos<= 10'd341 && button==4'b1000) 	
//				// Ball is trying to go up to wall 2 from the bottom, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end	
//					 
//				/*********************** DEALING WITH WALL 3 *********************************************/	 
//					
//				else if (Ball_X_Pos >=10'd167 && Ball_X_Pos<=10'd217 && Ball_Y_Pos>=10'd291 && Ball_Y_Pos<= 10'd341 && button==4'b0001) 	
//				// Ball is trying to go down to wall 3 from the top, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end
//					 
//				else if (Ball_X_Pos >=10'd218 && Ball_X_Pos<=10'd268 && Ball_Y_Pos>=10'd342 && Ball_Y_Pos<= 10'd392 && button==4'b0100) 	
//				// Ball is trying to go left to wall 3, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end	 
//					 
//				else if (Ball_X_Pos >=10'd116 && Ball_X_Pos<=10'd166 && Ball_Y_Pos>=10'd342 && Ball_Y_Pos<= 10'd392 && button==4'b0010) 	
//				// Ball is trying to go right to wall 3, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end	
//			
//				else if (Ball_X_Pos >=10'd167 && Ball_X_Pos<=10'd217 && Ball_Y_Pos>=10'd393 && Ball_Y_Pos<= 10'd443 && button==4'b1000) 	
//				// Ball is trying to go up to wall 3 from the bottom, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end	
//					 
//				/*********************** DEALING WITH WALL 4 *********************************************/	 
//			
//				else if (Ball_X_Pos >=10'd422 && Ball_X_Pos<=10'd523 && Ball_Y_Pos>=10'd87 && Ball_Y_Pos<= 10'd137 && button==4'b0001) 	
//				// Ball is trying to go down to wall 4 from the top, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end	
//					 
//				else if (Ball_X_Pos >=10'd371 && Ball_X_Pos<=10'd421 && Ball_Y_Pos>=10'd138 && Ball_Y_Pos<= 10'd188 && button==4'b0010) 	
//				// Ball is trying to go right to wall 4, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end		 
//					 
//				else if (Ball_X_Pos >=10'd422 && Ball_X_Pos<=10'd523 && Ball_Y_Pos>=10'd189 && Ball_Y_Pos<= 10'd239 && button==4'b1000) 	
//				// Ball is trying to go up to wall 4 from the bottom, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end		 
//					 
//				/*********************** DEALING WITH WALL 5 *********************************************/	 
//					
//				else if (Ball_X_Pos >=10'd422 && Ball_X_Pos<=10'd472 && Ball_Y_Pos>=10'd189 && Ball_Y_Pos<= 10'd239 && button==4'b0001) 	
//				// Ball is trying to go down to wall 5 from the top, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end	 	
//					 
//				else if (Ball_X_Pos >=10'd473 && Ball_X_Pos<=10'd523 && Ball_Y_Pos>=10'd240 && Ball_Y_Pos<= 10'd290 && button==4'b0100) 	
//				// Ball is trying to go left to wall 5, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end		 
//					 
//				else if (Ball_X_Pos >=10'd371 && Ball_X_Pos<=10'd421 && Ball_Y_Pos>=10'd240 && Ball_Y_Pos<= 10'd290 && button==4'b0010) 	
//				// Ball is trying to go right to wall 5, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end	
//				
//				else if (Ball_X_Pos >=10'd422 && Ball_X_Pos<=10'd472 && Ball_Y_Pos>=10'd291 && Ball_Y_Pos<= 10'd341 && button==4'b1000) 	
//				// Ball is trying to go up to wall 5 from the bottom, no movement!
//					 begin
//                Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 flag = 1'b1;
//					 end	
//					 
//				/*********************** END OF DEALING WITH WALLS *********************************************/
					 
            // TODO: Add other boundary detections and handle keypress here.
			//	else 
				
				
			//	begin
				case(button)
						
						
				4'b1000: // w = Up
				begin
					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
					Ball_Y_Motion_in = ~(Ball_Y_Step) + 1'b1; // 2's complement up
					flag = 1'b1;
				end

				4'b0100: // a = left
				begin
					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
					Ball_X_Motion_in = ~(Ball_X_Step) + 1'b1; // 2's complement left
				     flag = 1'b1;
				end

				4'b0001: // s = down
				begin
					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
					Ball_Y_Motion_in = Ball_Y_Step; // move down
					flag = 1'b1;

				end

				4'b0010: // d = right;
				begin
					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
					Ball_X_Motion_in = Ball_X_Step; // move right
					flag = 1'b1;

				end
				
				default:
					begin
					Ball_Y_Motion_in = 10'd0;
					Ball_X_Motion_in = 10'd0;
					flag = 1'b0;
					end

			endcase

	//	end		
				
				
				
				
            // Update the ball's position with its motion
            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
				
				if(Ball_X_Pos_in > Ball_X_Max | Ball_X_Pos_in < Ball_X_Min | Ball_Y_Pos_in > Ball_Y_Max | Ball_Y_Pos_in < Ball_Y_Min)
				begin
				Ball_X_Pos_in = Ball_X_Pos - Ball_X_Motion;
				Ball_Y_Pos_in = Ball_X_Pos - Ball_Y_Motion;
				flag = 1'b0;
				end
	
				
				/******* WALL 1 TOP LINE *******/
				else if(Ball_X_Pos_in > 10'd160 && Ball_X_Pos_in < 10'd275 && Ball_Y_Pos_in > 10'd80 && Ball_Y_Pos_in < 10'd144)
				begin
				Ball_X_Pos_in = Ball_X_Pos;
				Ball_Y_Pos_in = Ball_X_Pos;
				flag = 1'b0;
				end
				
				/****** WALL 1 VERTICAL LINE *****/
				else if(Ball_X_Pos_in > 10'd160 && Ball_X_Pos_in < 10'd224 && Ball_Y_Pos_in > 10'd80 && Ball_Y_Pos_in < 10'd195)
				begin
				Ball_X_Pos_in = Ball_X_Pos;
				Ball_Y_Pos_in = Ball_X_Pos;
				flag = 1'b0;
				end
				
				/***** WALL 2 ******/
				else if(Ball_X_Pos_in > 10'd213 && Ball_X_Pos_in < 10'd326 && Ball_Y_Pos_in > 10'd233 && Ball_Y_Pos_in < 10'd297)
				begin
				Ball_X_Pos_in = Ball_X_Pos;
				Ball_Y_Pos_in = Ball_X_Pos;
				flag = 1'b0;
				end
				
				/***** WALL 3 ******/
				else if(Ball_X_Pos_in > 10'd160 && Ball_X_Pos_in < 10'd224 && Ball_Y_Pos_in > 10'd335 && Ball_Y_Pos_in < 10'd399)
				begin
				Ball_X_Pos_in = Ball_X_Pos;
				Ball_Y_Pos_in = Ball_X_Pos;
				flag = 1'b0;
				end
				
				/***** WALL 4 ******/
				else if(Ball_X_Pos_in > 10'd415 && Ball_X_Pos_in < 10'd530 && Ball_Y_Pos_in > 10'd131 && Ball_Y_Pos_in < 10'd195)
				begin
				Ball_X_Pos_in = Ball_X_Pos;
				Ball_Y_Pos_in = Ball_X_Pos;
				flag = 1'b0;
				end
				
				/***** WALL 5 ******/
				else if(Ball_X_Pos_in > 10'd415 && Ball_X_Pos_in < 10'd479 && Ball_Y_Pos_in > 10'd233 && Ball_Y_Pos_in < 10'd297)
				begin
				Ball_X_Pos_in = Ball_X_Pos;
				Ball_Y_Pos_in = Ball_X_Pos;
				flag = 1'b0;
				end
				
        end
        
		  turndone = flag;
		  
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

////-------------------------------------------------------------------------
////    Ball.sv                                                            --
////    Viral Mehta                                                        --
////    Spring 2005                                                        --
////                                                                       --
////    Modified by Stephen Kempf 03-01-2006                               --
////                              03-12-2007                               --
////    Translated by Joe Meng    07-07-2013                               --
////    Modified by Po-Han Huang  12-08-2017                               --
////    Spring 2018 Distribution                                           --
////                                                                       --
////    For use with ECE 385 Lab 8                                         --
////    UIUC ECE Department                                                --
////-------------------------------------------------------------------------
////when white ball moves, mummy moves at well (Check FSM)
//
//module  ball ( input         Clk,                // 50 MHz clock
//                             Reset,              // Active-high reset signal
//									  Run,
//                             frame_clk,			 // The clock indicating a new frame (~60Hz)
//									  go,
//					input	[3:0]	  button,
//               input [9:0]   DrawX, DrawY, xcent, ycent,      // Current pixel coordinates
//               output logic  is_ball, turndone             // Whether current pixel belongs to ball or background
//              );
//    
//    parameter [9:0] Ball_X_Min = 10'd116;       // Leftmost point on the X axis
//    parameter [9:0] Ball_X_Max = 10'd523;     // Rightmost point on the X axis
//    parameter [9:0] Ball_Y_Min = 10'd36;       // Topmost point on the Y axis
//    parameter [9:0] Ball_Y_Max = 10'd443;     // Bottommost point on the Y axis
//    parameter [9:0] Ball_X_Step = 10'd26;      // Step size on the X axis changed from 1 to 10
//    parameter [9:0] Ball_Y_Step = 10'd26;      // Step size on the Y axis
//    parameter [9:0] Ball_Size = 10'd11;        // Ball size
//    
//    
//    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
//    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
//	 //logic counter, counterin;
//	 logic flag;
//    
//    //////// Do not modify the always_ff blocks. ////////
//    // Detect rising edge of frame_clk
//    logic frame_clk_delayed, frame_clk_rising_edge;
//    always_ff @ (posedge Clk) begin
//        frame_clk_delayed <= frame_clk;
//        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
//    end
//	 
//	 
//    // Update registers
//    always_ff @ (posedge Clk)
//    begin
//        if (Reset || Run)
//        begin
//            Ball_X_Pos <= xcent;
//            Ball_Y_Pos <= ycent;
//            Ball_X_Motion <= 10'd0;
//            Ball_Y_Motion <= 10'd0;
//				//counter <= 1'b0;
//        end
//        else
//        begin
//            Ball_X_Pos <= Ball_X_Pos_in;
//            Ball_Y_Pos <= Ball_Y_Pos_in;
//            Ball_X_Motion <= Ball_X_Motion_in; 
//            Ball_Y_Motion <= Ball_Y_Motion_in;
//				//counter <= counterin;
//        end
//    end
//    //////// Do not modify the always_ff blocks. ////////
//    
//    // You need to modify always_comb block.
//    always_comb
//    begin
//        // By default, keep motion and position unchanged
//        Ball_X_Pos_in = Ball_X_Pos;
//        Ball_Y_Pos_in = Ball_Y_Pos;
//        Ball_X_Motion_in = Ball_X_Motion;
//        Ball_Y_Motion_in = Ball_Y_Motion; //change from Ball_?_Motion;
//		  //counterin = counter;
//		  //turndone = 1'b0;
//        flag = 1'b0;
//		  
//        // Update position and motion only at rising edge of frame clock
//        if (frame_clk_rising_edge && go)
//        begin
//            // Be careful when using comparators with "logic" datatype because compiler treats 
//            //   both sides of the operator as UNSIGNED numbers.
//            // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
//            // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
//				
//            if( Ball_Y_Pos + Ball_Size + Ball_Y_Step >= Ball_Y_Max) 	// Ball is at the bottom edge, BOUNCE!
//					 begin
//                Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);//changed from (~(Ball_Y_Step) + 1'b1);// 2's complement.
//					 Ball_X_Motion_in = 10'd0;
//					 //turndone = 1'b0;
//					 //counterin = counter + 1'b1;
//					 end
//					 
//            else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size + Ball_Y_Step)  // Ball is at the top edge, BOUNCE!
//						begin
//						Ball_Y_Motion_in  = Ball_Y_Step; // changed from Ball_Y_Step; //add 1?
//						Ball_X_Motion_in = 10'd0;
//						//turndone = 1'b0;
//						//counterin = counter + 1'b1;
//						end
//				else	 
//				
//				if( Ball_X_Pos + Ball_Size + Ball_X_Step >= Ball_X_Max)  // Ball is at the right edge, BOUNCE!
//					 begin
//                Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1); // 2's complement. Changed from (~(Ball_X_Step) + 1'b1)
//					 Ball_Y_Motion_in = 10'd0;
//					 //turndone = 1'b0;
//					 //counterin = counter + 1'b1;
//					 end
//            else if ( Ball_X_Pos <= Ball_X_Min + Ball_Size + Ball_X_Step)  // Ball is at the left edge, BOUNCE!   Don't move!!! //add step?
//					 begin
//                Ball_X_Motion_in = Ball_X_Step; //changed from Ball_X_Step
//					 Ball_Y_Motion_in = 10'd0;
//					 //turndone = 1'b0;
//					 //counterin = counter + 1'b1;
//					 end
//					 
//            // TODO: Add other boundary detections and handle keypress here.
//				else 
//				
//				
//				begin
//				case(button)
//						
//						
//				4'b1000: // w = Up
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = ~(Ball_Y_Step) + 1'b1; // 2's complement up
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//				end
//
//				4'b0100: // a = left
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = ~(Ball_X_Step) + 1'b1; // 2's complement left
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//				     flag = 1'b1;
//				end
//
//				4'b0001: // s = down
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = Ball_Y_Step; // move down
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//
//				end
//
//				4'b0010: // d = right;
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = Ball_X_Step; // move right
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//
//				end
//				
//				default:
//					begin
//					Ball_Y_Motion_in = 10'd0;
//					Ball_X_Motion_in = 10'd0;
//					//turndone = 1'b0;
//					flag = 1'b0;
//					end
//
//			endcase
//
//		end		
//				
//				
//				
//				
//            // Update the ball's position with its motion
//            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
//            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
//        end
//        
//		  turndone = flag;
//        /**************************************************************************************
//            ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
//            Hidden Question #2/2:
//               Notice that Ball_Y_Pos is updated using Ball_Y_Motion. 
//              Will the new value of Ball_Y_Motion be used when Ball_Y_Pos is updated, or the old? 
//              What is the difference between writing
//                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;" and 
//                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;"?
//              How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
//              Give an answer in your Post-Lab.
//        **************************************************************************************/
//    end
//    
//    // Compute whether the pixel corresponds to ball or background
//    /* Since the multiplicants are required to be signed, we have to first cast them
//       from logic to int (signed by default) before they are multiplied. */
//    int DistX, DistY, Size;
//    assign DistX = DrawX - Ball_X_Pos;
//    assign DistY = DrawY - Ball_Y_Pos;
//    assign Size = Ball_Size;
//    always_comb begin
//        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
//            is_ball = 1'b1;
//        else
//            is_ball = 1'b0;
//        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
//           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
//           of the 12 available multipliers on the chip! */
//    end
//    
//endmodule

//module  ball ( input         Clk,                // 50 MHz clock
//                             Reset,              // Active-high reset signal
//									  Run,
//                             frame_clk,			 // The clock indicating a new frame (~60Hz)
//									  go,
//					input	[3:0]	  button,
//               input [9:0]   DrawX, DrawY, xcent, ycent,      // Current pixel coordinates
//               output logic  is_ball, turndone,             // Whether current pixel belongs to ball or background
//					output [9:0] xout, yout
//              );
//    
//    parameter [9:0] Ball_X_Min = 10'd116;       // Leftmost point on the X axis
//    parameter [9:0] Ball_X_Max = 10'd523;     // Rightmost point on the X axis
//    parameter [9:0] Ball_Y_Min = 10'd36;       // Topmost point on the Y axis
//    parameter [9:0] Ball_Y_Max = 10'd443;     // Bottommost point on the Y axis
//    parameter [9:0] Ball_X_Step = 10'd25;      // Step size on the X axis changed from 1 to 10
//    parameter [9:0] Ball_Y_Step = 10'd25;      // Step size on the Y axis
//    parameter [9:0] Ball_Size = 10'd11;        // Ball size
//    
//    
//    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
//    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
//	 //logic counter, counterin;
//	 logic flag;
//    
//    //////// Do not modify the always_ff blocks. ////////
//    // Detect rising edge of frame_clk
//    logic frame_clk_delayed, frame_clk_rising_edge;
//    always_ff @ (posedge Clk) begin
//        frame_clk_delayed <= frame_clk;
//        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
//    end
//	 
//	 
//    // Update registers
//    always_ff @ (posedge Clk)
//    begin
//        if (Reset || Run)
//        begin
//            Ball_X_Pos <= xcent;
//            Ball_Y_Pos <= ycent;
//            Ball_X_Motion <= 10'd0;
//            Ball_Y_Motion <= 10'd0;
//				//counter <= 1'b0;
//        end
//        else
//        begin
//            Ball_X_Pos <= Ball_X_Pos_in;
//            Ball_Y_Pos <= Ball_Y_Pos_in;
//            Ball_X_Motion <= Ball_X_Motion_in; 
//            Ball_Y_Motion <= Ball_Y_Motion_in;
//				//counter <= counterin;
//        end
//    end
//    //////// Do not modify the always_ff blocks. ////////
//    
//    // You need to modify always_comb block.
//    always_comb
//    begin
//        // By default, keep motion and position unchanged
//        Ball_X_Pos_in = Ball_X_Pos;
//        Ball_Y_Pos_in = Ball_Y_Pos;
//        Ball_X_Motion_in = Ball_X_Motion;
//        Ball_Y_Motion_in = Ball_Y_Motion; //change from Ball_?_Motion;
//		  //counterin = counter;
//		  //turndone = 1'b0;
//        flag = 1'b0;
//		  
//        // Update position and motion only at rising edge of frame clock
//        if (frame_clk_rising_edge && go)
//        begin
//            // Be careful when using comparators with "logic" datatype because compiler treats 
//            //   both sides of the operator as UNSIGNED numbers.
//            // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
//            // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
//				
//				
//				/*******************************************************************************************************/		
//            if( ( Ball_Y_Pos + Ball_Size + Ball_Y_Step >= Ball_Y_Max) && ( Ball_X_Pos + Ball_Size + Ball_X_Step >= Ball_X_Max) )	// Ball is at the bottom-right square
//					 begin
//                
//					 
//					 case(button)
//						
//						
//				4'b1000: // w = Up
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = ~(Ball_Y_Step) + 1'b1; // 2's complement up
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//				end
//
//				4'b0100: // a = left
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = ~(Ball_X_Step) + 1'b1; // 2's complement left
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//				     flag = 1'b1;
//				end
//
//				4'b0001: // s = down
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = 10'd0; // move down
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b0;
//
//				end
//
//				4'b0010: // d = right;
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = 10'd0; // move right
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b0;
//
//				end
//				
//				default:
//					begin
//					Ball_Y_Motion_in = 10'd0;
//					Ball_X_Motion_in = 10'd0;
//					//turndone = 1'b0;
//					flag = 1'b0;
//					end
//
//			endcase
//					 
//					 end
//					 
//					 
//		
//				/*******************************************************************************************************/		
//            else if( (Ball_Y_Pos + Ball_Size + Ball_Y_Step >= Ball_Y_Max) && ( Ball_X_Pos <= Ball_X_Min + Ball_Size + Ball_X_Step))	// Ball is at the bottom-left square
//					 begin
//                
//					 
//					 case(button)
//						
//						
//				4'b1000: // w = Up
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = ~(Ball_Y_Step) + 1'b1; // 2's complement up
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//				end
//
//				4'b0100: // a = left
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = 10'd0; // 2's complement left
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//				     flag = 1'b0;
//				end
//
//				4'b0001: // s = down
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = 10'd0; // move down
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b0;
//
//				end
//
//				4'b0010: // d = right;
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = Ball_X_Step; // move right
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//
//				end
//				
//				default:
//					begin
//					Ball_Y_Motion_in = 10'd0;
//					Ball_X_Motion_in = 10'd0;
//					//turndone = 1'b0;
//					flag = 1'b0;
//					end
//
//			endcase
//					 
//					 end
//					 
//					 /*******************************************************************************************************/		
//					 
//            else if ( (Ball_Y_Pos <= Ball_Y_Min + Ball_Size + Ball_Y_Step) && ( Ball_X_Pos <= Ball_X_Min + Ball_Size + Ball_X_Step))  // Ball is at the top-left square
//						begin
//						
//						case(button)
//						
//						
//				4'b1000: // w = Up
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = 10'd0; // 2's complement up
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b0;
//				end
//
//				4'b0100: // a = left
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = 10'd0; // 2's complement left
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//				     flag = 1'b0;
//				end
//
//				4'b0001: // s = down
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = Ball_Y_Step; // move down
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//
//				end
//
//				4'b0010: // d = right;
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = Ball_X_Step; // move right
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//
//				end
//				
//				default:
//					begin
//					Ball_Y_Motion_in = 10'd0;
//					Ball_X_Motion_in = 10'd0;
//					//turndone = 1'b0;
//					flag = 1'b0;
//					end
//
//			endcase
//						
//						end
//						
//						/*******************************************************************************************************/		
//					 
//            else if ( (Ball_Y_Pos <= Ball_Y_Min + Ball_Size + Ball_Y_Step) && ( Ball_X_Pos + Ball_Size + Ball_X_Step >= Ball_X_Max) )  // Ball is at the top-right square
//						begin
//						
//						case(button)
//						
//						
//				4'b1000: // w = Up
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = 10'd0; // 2's complement up
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b0;
//				end
//
//				4'b0100: // a = left
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = ~(Ball_X_Step) + 1'b1; // 2's complement left
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//				     flag = 1'b1;
//				end
//
//				4'b0001: // s = down
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = Ball_Y_Step; // move down
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//
//				end
//
//				4'b0010: // d = right;
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = 10'd0; // move right
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b0;
//
//				end
//				
//				default:
//					begin
//					Ball_Y_Motion_in = 10'd0;
//					Ball_X_Motion_in = 10'd0;
//					//turndone = 1'b0;
//					flag = 1'b0;
//					end
//
//			endcase
//						
//						end
//				
//				
//		/*******************************************************************************************************/		
//            else if( Ball_Y_Pos + Ball_Size + Ball_Y_Step >= Ball_Y_Max) 	// Ball is at the bottom edge, BOUNCE!
//					 begin
//                
//					 
//					 case(button)
//						
//						
//				4'b1000: // w = Up
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = ~(Ball_Y_Step) + 1'b1; // 2's complement up
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//				end
//
//				4'b0100: // a = left
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = ~(Ball_X_Step) + 1'b1; // 2's complement left
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//				     flag = 1'b1;
//				end
//
//				4'b0001: // s = down
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = 10'd0; // move down
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b0;
//
//				end
//
//				4'b0010: // d = right;
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = Ball_X_Step; // move right
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//
//				end
//				
//				default:
//					begin
//					Ball_Y_Motion_in = 10'd0;
//					Ball_X_Motion_in = 10'd0;
//					//turndone = 1'b0;
//					flag = 1'b0;
//					end
//
//			endcase
//					 
//					 end
//					 
//					 
//		/*******************************************************************************************************/		
//					 
//            else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size + Ball_Y_Step)  // Ball is at the top edge, BOUNCE!
//						begin
//						
//						case(button)
//						
//						
//				4'b1000: // w = Up
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = 10'd0; // 2's complement up
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b0;
//				end
//
//				4'b0100: // a = left
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = ~(Ball_X_Step) + 1'b1; // 2's complement left
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//				     flag = 1'b1;
//				end
//
//				4'b0001: // s = down
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = Ball_Y_Step; // move down
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//
//				end
//
//				4'b0010: // d = right;
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = Ball_X_Step; // move right
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//
//				end
//				
//				default:
//					begin
//					Ball_Y_Motion_in = 10'd0;
//					Ball_X_Motion_in = 10'd0;
//					//turndone = 1'b0;
//					flag = 1'b0;
//					end
//
//			endcase
//						
//						end
//						
//						
//		/*******************************************************************************************************/		
//				else	 
//				
//				if( Ball_X_Pos + Ball_Size + Ball_X_Step >= Ball_X_Max)  // Ball is at the right edge, BOUNCE!
//					 begin
//                
//					 case(button)
//						
//						
//				4'b1000: // w = Up
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = ~(Ball_Y_Step) + 1'b1; // 2's complement up
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//				end
//
//				4'b0100: // a = left
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = ~(Ball_X_Step) + 1'b1; // 2's complement left
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//				     flag = 1'b1;
//				end
//
//				4'b0001: // s = down
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = Ball_Y_Step; // move down
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//
//				end
//
//				4'b0010: // d = right;
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = 10'd0; // move right
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b0;
//
//				end
//				
//				default:
//					begin
//					Ball_Y_Motion_in = 10'd0;
//					Ball_X_Motion_in = 10'd0;
//					//turndone = 1'b0;
//					flag = 1'b0;
//					end
//
//			endcase
//					 
//					 end
//					 
//					 
//		/*******************************************************************************************************/		
//					 
//            else if ( Ball_X_Pos <= Ball_X_Min + Ball_Size + Ball_X_Step)  // Ball is at the left edge, BOUNCE!   Don't move!!! //add step?
//					 begin
//                
//					 case(button)
//						
//						
//				4'b1000: // w = Up
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = ~(Ball_Y_Step) + 1'b1; // 2's complement up
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//				end
//
//				4'b0100: // a = left
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = 10'd0; // 2's complement left
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//				     flag = 1'b0;
//				end
//
//				4'b0001: // s = down
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = Ball_Y_Step; // move down
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//
//				end
//
//				4'b0010: // d = right;
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = Ball_X_Step; // move right
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//
//				end
//				
//				default:
//					begin
//					Ball_Y_Motion_in = 10'd0;
//					Ball_X_Motion_in = 10'd0;
//					//turndone = 1'b0;
//					flag = 1'b0;
//					end
//
//			endcase
//					 
//					 end
//					 
//					 
//		/*******************************************************************************************************/		
//					 
//            // TODO: Add other boundary detections and handle keypress here.
//				else 
//				
//				
//				begin
//				case(button)
//						
//						
//				4'b1000: // w = Up
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = ~(Ball_Y_Step) + 1'b1; // 2's complement up
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//				end
//
//				4'b0100: // a = left
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = ~(Ball_X_Step) + 1'b1; // 2's complement left
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//				     flag = 1'b1;
//				end
//
//				4'b0001: // s = down
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = Ball_Y_Step; // move down
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//
//				end
//
//				4'b0010: // d = right;
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = Ball_X_Step; // move right
//					//turndone = 1'b1;
//					//counterin = counter + 1'b1;
//					flag = 1'b1;
//
//				end
//				
//				default:
//					begin
//					Ball_Y_Motion_in = 10'd0;
//					Ball_X_Motion_in = 10'd0;
//					//turndone = 1'b0;
//					flag = 1'b0;
//					end
//
//			endcase
//
//		end		
//				
//				
//				
//				
//            // Update the ball's position with its motion
//            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
//            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
//        end
//        
//		  turndone = flag;
//        /**************************************************************************************
//            ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
//            Hidden Question #2/2:
//               Notice that Ball_Y_Pos is updated using Ball_Y_Motion. 
//              Will the new value of Ball_Y_Motion be used when Ball_Y_Pos is updated, or the old? 
//              What is the difference between writing
//                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;" and 
//                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;"?
//              How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
//              Give an answer in your Post-Lab.
//        **************************************************************************************/
//    end
//    
//    // Compute whether the pixel corresponds to ball or background
//    /* Since the multiplicants are required to be signed, we have to first cast them
//       from logic to int (signed by default) before they are multiplied. */
//    int DistX, DistY, Size;
//    assign DistX = DrawX - Ball_X_Pos;
//    assign DistY = DrawY - Ball_Y_Pos;
//    assign Size = Ball_Size;
//	 assign xout = Ball_X_Pos;
//	 assign yout = Ball_Y_Pos;
//    always_comb begin
//        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
//            is_ball = 1'b1;
//        else
//            is_ball = 1'b0;
//        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
//           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
//           of the 12 available multipliers on the chip! */
//    end
//    
//endmodule




////-------------------------------------------------------------------------
////    Ball.sv                                                            --
////    Viral Mehta                                                        --
////    Spring 2005                                                        --
////                                                                       --
////    Modified by Stephen Kempf 03-01-2006                               --
////                              03-12-2007                               --
////    Translated by Joe Meng    07-07-2013                               --
////    Modified by Po-Han Huang  12-08-2017                               --
////    Spring 2018 Distribution                                           --
////                                                                       --
////    For use with ECE 385 Lab 8                                         --
////    UIUC ECE Department                                                --
////-------------------------------------------------------------------------
//
//
//module  ball ( input         Clk,                // 50 MHz clock
//                             Reset,              // Active-high reset signal
//                             frame_clk,			 // The clock indicating a new frame (~60Hz)
//									  go,
//					input	[3:0]	  button,
//               input [9:0]   DrawX, DrawY, xcent, ycent,      // Current pixel coordinates
//               output logic  is_ball, turndone             // Whether current pixel belongs to ball or background
//              );
//    
//   // logic [9:0] Ball_X_Center = xcent;  // Center position on the X axis
//    //logic [9:0] Ball_Y_Center = ycent;  // Center position on the Y axis
//    parameter [9:0] Ball_X_Min = 10'd116;       // Leftmost point on the X axis
//    parameter [9:0] Ball_X_Max = 10'd523;     // Rightmost point on the X axis
//    parameter [9:0] Ball_Y_Min = 10'd36;       // Topmost point on the Y axis
//    parameter [9:0] Ball_Y_Max = 10'd443;     // Bottommost point on the Y axis
//    parameter [9:0] Ball_X_Step = 10'd1;      // Step size on the X axis changed from 1 to 10
//    parameter [9:0] Ball_Y_Step = 10'd1;      // Step size on the Y axis
//    parameter [9:0] Ball_Size = 10'd11;        // Ball size
//    
//    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
//    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
//	 //logic [5:0] counter, counterin;
//
//	 
//	 //logic [9:0] tempXleft, tempXright, tempYup, tempYdown, tempXleft_in, tempXright_in, tempYup_in, tempYdown_in;
//	 /*assign tempXleft = DrawX - 10'd60; 
//	 assign tempYup = DrawY - 10'd60;
//    assign tempXright = DrawX + 10'd60;
//	 assign tempYdown = DrawY + 10'd60;*/
//	 
//	 // VGA BLANK N DICTATES THE END OF A FRAME
//	 
//	 
//	 
//	 	    // Update registers
//    always_ff @ (posedge Clk)
//    begin
//        if (Reset)
//        begin
//            Ball_X_Pos <= xcent;
//            Ball_Y_Pos <= ycent;
//            Ball_X_Motion <= 10'd0;
//            Ball_Y_Motion <= 10'd0;
//				//counter <= 6'd0;
//        end
//		  
//        else
//        begin
//            Ball_X_Pos <= Ball_X_Pos_in;
//            Ball_Y_Pos <= Ball_Y_Pos_in;
//            Ball_X_Motion <= Ball_X_Motion_in; 
//            Ball_Y_Motion <= Ball_Y_Motion_in;
//				//counter <= counterin;
//        end
//    end
//
//	 
//	 
//    //////// Do not modify the always_ff blocks. ////////
//    // Detect rising edge of frame_clk
//    logic frame_clk_delayed, frame_clk_rising_edge;
//    always_ff @ (posedge Clk) begin
//        frame_clk_delayed <= frame_clk;
//        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
//    end
//	 
//    
//    // You need to modify always_comb block.
//    always_comb
//    begin
//        // By default, keep motion and position unchanged
//        Ball_X_Pos_in = Ball_X_Pos;
//        Ball_Y_Pos_in = Ball_Y_Pos;
//        Ball_X_Motion_in = Ball_X_Motion;
//        Ball_Y_Motion_in = Ball_Y_Motion; //change from Ball_?_Motion;
//        
//        // Update position and motion only at rising edge of frame clock
//        if (frame_clk_rising_edge && go)
//        begin
//
//				case(button)
//						
//						
//				4'b1000: // w = Up
//				begin
//				
//				//counterin = counter + 6'd1;
//				
//				//if(Ball_Y_Pos < (Ball_Y_Min + ((Ball_Y_Step- 1'b1)/2) ) )
//				if(Ball_Y_Pos < (Ball_Y_Min + Ball_Y_Step) )
//				begin
//				Ball_Y_Motion_in = 10'd0;
//				Ball_X_Motion_in = 10'd0;
//				turndone = 1'b0;
//				end
//				
//				else
//				begin
//				Ball_X_Motion_in = 10'd0;
//				Ball_Y_Motion_in =  ~(Ball_Y_Step) + 1'b1;
//				turndone = 1'b1;
//				end
//				
//				
//				end
//
//				4'b0100: // a = left
//				begin
//				
//				//counterin = counter + 6'd1;
//				//if(Ball_X_Pos < (Ball_X_Min + Ball_X_Step - 1'b1)/2) ) )
//				if(Ball_X_Pos < (Ball_X_Min + Ball_X_Step) )
//				begin
//				Ball_Y_Motion_in = 10'd0;
//				Ball_X_Motion_in = 10'd0;
//				turndone = 1'b0;
//				end
//				
//				else
//				begin
//				Ball_Y_Motion_in = 10'd0;
//				Ball_X_Motion_in = ~(Ball_X_Step) + 1'b1;
//				turndone = 1'b1;
//				end
//				
//
//				end
//
//				4'b0001: // s = down
//				begin
//				//counterin = counter + 6'd1;
//				if(Ball_Y_Pos > (Ball_Y_Max - Ball_Y_Step))
//				begin
//				Ball_Y_Motion_in = 10'd0;
//				Ball_X_Motion_in = 10'd0;
//				turndone = 1'b0;
//				end
//				
//				else
//				begin
//				Ball_X_Motion_in = 10'd0;
//				Ball_Y_Motion_in = Ball_Y_Step;
//				turndone = 1'b1;
//				end
//
//				end
//
//				4'b0010: // d = right;
//				begin
//				//counterin = counter + 6'd1;
//				
//				//if(Ball_X_Pos > Ball_X_Max - ((Ball_X_Step - 1'b1)/2) )
//				if(Ball_X_Pos > (Ball_X_Max - Ball_X_Step) )
//				begin
//				Ball_Y_Motion_in = 10'd0;
//				Ball_X_Motion_in = 10'd0;
//				turndone = 1'b0;
//				end
//				
//				else
//				begin
//				Ball_Y_Motion_in = 10'd0;
//				Ball_X_Motion_in = Ball_X_Step;
//				turndone = 1'b1;
//				end
//					
//
//				end
//				
//				default:
//					begin
//					Ball_Y_Motion_in = 10'd0;
//					Ball_X_Motion_in = 10'd0;
//					turndone = 1'b0;
//					end
//
//			endcase
//
//		  end		
//		  
//		  else
//		  begin
//		  turndone = 1'b0;
//		  end
//		  
////		  else if (~blank)
////		  begin
////		  Ball_Y_Motion_in = 10'd0;
////		  Ball_X_Motion_in = 10'd0;
////		  end
//				
//            // Update the ball's position with its motion
//            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
//            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
//        end
//        
//        /**************************************************************************************
//            ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
//            Hidden Question #2/2:
//               Notice that Ball_Y_Pos is updated using Ball_Y_Motion. 
//              Will the new value of Ball_Y_Motion be used when Ball_Y_Pos is updated, or the old? 
//              What is the difference between writing
//                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;" and 
//                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;"?
//              How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
//              Give an answer in your Post-Lab.
//        **************************************************************************************/
//    
//
//    // Compute whether the pixel corresponds to ball or background
//    /* Since the multiplicants are required to be signed, we have to first cast them
//       from logic to int (signed by default) before they are multiplied. */
//    int DistX, DistY, Size;
//    assign DistX = DrawX - Ball_X_Pos;
//    assign DistY = DrawY - Ball_Y_Pos;
//    assign Size = Ball_Size;
//    always_comb begin
//        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
//            is_ball = 1'b1;
//        else
//            is_ball = 1'b0;
//        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
//           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
//           of the 12 available multipliers on the chip! */
//    end
//    
//endmodule









////-------------------------------------------------------------------------
////    Ball.sv                                                            --
////    Viral Mehta                                                        --
////    Spring 2005                                                        --
////                                                                       --
////    Modified by Stephen Kempf 03-01-2006                               --
////                              03-12-2007                               --
////    Translated by Joe Meng    07-07-2013                               --
////    Modified by Po-Han Huang  12-08-2017                               --
////    Spring 2018 Distribution                                           --
////                                                                       --
////    For use with ECE 385 Lab 8                                         --
////    UIUC ECE Department                                                --
////-------------------------------------------------------------------------
//
//
//module  ball ( input         Clk,                // 50 MHz clock
//                             Reset,              // Active-high reset signal
//                             frame_clk,			 // The clock indicating a new frame (~60Hz)
//					input	[3:0]	  button,
//               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
//               output logic  is_ball, turnDone             // Whether current pixel belongs to ball or background
//              );
//    
//    parameter [9:0] Ball_X_Center = 10'd498;  // Center position on the X axis
//    parameter [9:0] Ball_Y_Center = 10'd418;  // Center position on the Y axis
//    parameter [9:0] Ball_X_Min = 10'd116;       // Leftmost point on the X axis
//    parameter [9:0] Ball_X_Max = 10'd523;     // Rightmost point on the X axis
//    parameter [9:0] Ball_Y_Min = 10'd36;       // Topmost point on the Y axis
//    parameter [9:0] Ball_Y_Max = 10'd443;     // Bottommost point on the Y axis
//    parameter [9:0] Ball_X_Step = 10'd51;      // Step size on the X axis changed from 1 to 10
//    parameter [9:0] Ball_Y_Step = 10'd51;      // Step size on the Y axis
//    parameter [9:0] Ball_Size = 10'd10;        // Ball size
//    
//    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
//    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
//
//	 
//	 //logic [9:0] tempXleft, tempXright, tempYup, tempYdown, tempXleft_in, tempXright_in, tempYup_in, tempYdown_in;
//	 /*assign tempXleft = DrawX - 10'd60; 
//	 assign tempYup = DrawY - 10'd60;
//    assign tempXright = DrawX + 10'd60;
//	 assign tempYdown = DrawY + 10'd60;*/
//	 
//	 
//	 
//	 	    // Update registers
//    always_ff @ (posedge Clk)
//    begin
//        if (Reset)
//        begin
//            Ball_X_Pos <= Ball_X_Center;
//            Ball_Y_Pos <= Ball_Y_Center;
//            Ball_X_Motion <= 10'd0;
//            Ball_Y_Motion <= 10'd0;
//        end
//		  
//        else
//        begin
//            Ball_X_Pos <= Ball_X_Pos_in;
//            Ball_Y_Pos <= Ball_Y_Pos_in;
//            Ball_X_Motion <= Ball_X_Motion_in; 
//            Ball_Y_Motion <= Ball_Y_Motion_in;
//        end
//    end
//
//	 
//	 
//    //////// Do not modify the always_ff blocks. ////////
//    // Detect rising edge of frame_clk
//    logic frame_clk_delayed, frame_clk_rising_edge;
//    always_ff @ (posedge Clk) begin
//        frame_clk_delayed <= frame_clk;
//        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
//    end
//	 
//	 
//	 
//	 
//	 
//	 
//	 
//	 
//	 
//	 
//	 
//    
//    // You need to modify always_comb block.
//    always_comb
//    begin
//        // By default, keep motion and position unchanged
//        Ball_X_Pos_in = Ball_X_Pos;
//        Ball_Y_Pos_in = Ball_Y_Pos;
//        Ball_X_Motion_in = Ball_X_Motion;
//        Ball_Y_Motion_in = Ball_Y_Motion; //change from Ball_?_Motion;
//        
//        // Update position and motion only at rising edge of frame clock
//        if (frame_clk_rising_edge)
//        begin
//
//				case(button)
//						
//						
//				4'b1000: // w = Up
//				begin
//				
//				if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size + Ball_Y_Step)  // Ball is at the top edge, BOUNCE!
//						begin
//						Ball_Y_Motion_in  = Ball_Y_Step; // changed from Ball_Y_Step; //add 1?
//						Ball_X_Motion_in = 10'd0;
//						end
//					
//					else
//					begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = ~(Ball_Y_Step) + 1'b1; // 2's complement up
//					end
//					
//				end
//
//				4'b0100: // a = left
//				begin
//				
//					if ( Ball_X_Pos <= Ball_X_Min + Ball_Size + Ball_X_Step)  // Ball is at the left edge, BOUNCE!   Don't move!!! //add step?
//					begin
//						Ball_X_Motion_in = Ball_X_Step; //changed from Ball_X_Step
//						Ball_Y_Motion_in = 10'd0;
//					end
//				
//					else
//					begin
//						Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//						Ball_X_Motion_in = ~(Ball_X_Step) + 1'b1; // 2's complement left
//					end
//
//				end
//
//				4'b0001: // s = down
//				begin
//				
//					if( Ball_Y_Pos + Ball_Size + Ball_Y_Step >= Ball_Y_Max) 	// Ball is at the bottom edge, BOUNCE!
//					 begin
//						Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);//changed from (~(Ball_Y_Step) + 1'b1);// 2's complement.
//						Ball_X_Motion_in = 10'd0;
//					 end
//				
//					else
//					begin
//						Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//						Ball_Y_Motion_in = Ball_Y_Step; // move down
//					end
//
//				end
//
//				4'b0010: // d = right;
//				begin
//				
//					 if( Ball_X_Pos + Ball_Size + Ball_X_Step >= Ball_X_Max)  // Ball is at the right edge, BOUNCE!
//					 begin
//						Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1); // 2's complement. Changed from (~(Ball_X_Step) + 1'b1)
//						Ball_Y_Motion_in = 10'd0;
//					 end
//				
//					else
//					begin
//						Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//						Ball_X_Motion_in = Ball_X_Step; // move right
//					end
//
//				end
//				
//				default:
//					begin
//					Ball_Y_Motion_in = 10'd0;
//					Ball_X_Motion_in = 10'd0;
//					end
//
//			endcase
//
//		  end		
//				
//            // Update the ball's position with its motion
//            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
//            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
//        end
//        
//        /**************************************************************************************
//            ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
//            Hidden Question #2/2:
//               Notice that Ball_Y_Pos is updated using Ball_Y_Motion. 
//              Will the new value of Ball_Y_Motion be used when Ball_Y_Pos is updated, or the old? 
//              What is the difference between writing
//                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;" and 
//                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;"?
//              How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
//              Give an answer in your Post-Lab.
//        **************************************************************************************/
// //   end
//    
//
//    // Compute whether the pixel corresponds to ball or background
//    /* Since the multiplicants are required to be signed, we have to first cast them
//       from logic to int (signed by default) before they are multiplied. */
//    int DistX, DistY, Size;
//    assign DistX = DrawX - Ball_X_Pos;
//    assign DistY = DrawY - Ball_Y_Pos;
//    assign Size = Ball_Size;
//    always_comb begin
//        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
//            is_ball = 1'b1;
//        else
//            is_ball = 1'b0;
//        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
//           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
//           of the 12 available multipliers on the chip! */
//    end
//    
//endmodule
//










////-------------------------------------------------------------------------
////    Ball.sv                                                            --
////    Viral Mehta                                                        --
////    Spring 2005                                                        --
////                                                                       --
////    Modified by Stephen Kempf 03-01-2006                               --
////                              03-12-2007                               --
////    Translated by Joe Meng    07-07-2013                               --
////    Modified by Po-Han Huang  12-08-2017                               --
////    Spring 2018 Distribution                                           --
////                                                                       --
////    For use with ECE 385 Lab 8                                         --
////    UIUC ECE Department                                                --
////-------------------------------------------------------------------------
//
//
//module  ball ( input         Clk,                // 50 MHz clock
//                             Reset,              // Active-high reset signal
//                             frame_clk,			 // The clock indicating a new frame (~60Hz)
//					input	[3:0]	  button,
//               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
//               output logic  is_ball, turnDone             // Whether current pixel belongs to ball or background
//              );
//    
//    parameter [9:0] Ball_X_Center = 10'd590;  // Center position on the X axis
//    parameter [9:0] Ball_Y_Center = 10'd360;  // Center position on the Y axis
//    parameter [9:0] Ball_X_Min = 10'd20;       // Leftmost point on the X axis
//    parameter [9:0] Ball_X_Max = 10'd619;     // Rightmost point on the X axis
//    parameter [9:0] Ball_Y_Min = 10'd30;       // Topmost point on the Y axis
//    parameter [9:0] Ball_Y_Max = 10'd449;     // Bottommost point on the Y axis
//    parameter [9:0] Ball_X_Step = 10'd60;      // Step size on the X axis changed from 1 to 10
//    parameter [9:0] Ball_Y_Step = 10'd60;      // Step size on the Y axis
//    parameter [9:0] Ball_Size = 10'd10;        // Ball size
//    
//    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
//    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
//	 logic turnDone_in;
//	 
//	 
//	 logic [9:0] tempXleft, tempXright, tempYup, tempYdown, tempXleft_in, tempXright_in, tempYup_in, tempYdown_in;
//	 /*assign tempXleft = DrawX - 10'd60; 
//	 assign tempYup = DrawY - 10'd60;
//    assign tempXright = DrawX + 10'd60;
//	 assign tempYdown = DrawY + 10'd60;*/
//	 
//    //////// Do not modify the always_ff blocks. ////////
//    // Detect rising edge of frame_clk
//    logic frame_clk_delayed, frame_clk_rising_edge;
//    always_ff @ (posedge Clk) begin
//        frame_clk_delayed <= frame_clk;
//        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
//    end
//	 
//	 
//    // Update registers
//    always_ff @ (posedge Clk)
//    begin
//        if (Reset)
//        begin
//            Ball_X_Pos <= Ball_X_Center;
//            Ball_Y_Pos <= Ball_Y_Center;
//            Ball_X_Motion <= 10'd0;
//            Ball_Y_Motion <= 10'd0;
//				turnDone <= 1'b0;
//				tempXleft <= 10'd200; 
//				tempYup <= 10'd200;
//				tempXright <= 10'd650;
//				tempYdown <= 10'd460;
//        end
//        else
//        begin
//            Ball_X_Pos <= Ball_X_Pos_in;
//            Ball_Y_Pos <= Ball_Y_Pos_in;
//            Ball_X_Motion <= Ball_X_Motion_in; 
//            Ball_Y_Motion <= Ball_Y_Motion_in;
//				turnDone <= turnDone_in;
//				tempXleft <= tempXleft_in; 
//				tempYup <= tempYup_in;
//				tempXright <= tempXright_in;
//				tempYdown <= tempYdown_in;
//        end
//    end
//    //////// Do not modify the always_ff blocks. ////////
//    
//    // You need to modify always_comb block.
//    always_comb
//    begin
//        // By default, keep motion and position unchanged
//        Ball_X_Pos_in = Ball_X_Pos;
//        Ball_Y_Pos_in = Ball_Y_Pos;
//        Ball_X_Motion_in = Ball_X_Motion;
//        Ball_Y_Motion_in = Ball_Y_Motion; //change from Ball_?_Motion;
//        
//        // Update position and motion only at rising edge of frame clock
//        if (frame_clk_rising_edge)
//        begin
//		  
//		  case(button)
//						
//						
//				4'b1000: // w = Up
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					tempYup_in = DrawY - 10'd60;
//				
//					if(tempYup < 10'd55)
//					begin
//						Ball_Y_Motion_in = 10'd0;
//						turnDone_in = 1'b0;
//					end
//					
//					else
//					begin
//					Ball_Y_Motion_in = ~(Ball_Y_Step) + 1'b1; // 2's complement up
//					turnDone_in = 1'b1;
//					end
//
//				end
//
//				4'b0100: // a = left
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					tempXleft_in = DrawX - 10'd60;
//					if(tempXleft < 10'd35)
//					begin
//					Ball_X_Motion_in = 10'd0;
//					turnDone_in = 1'b0;
//					end
//					
//					else
//					begin
//					Ball_X_Motion_in = ~(Ball_X_Step) + 1'b1; // 2's complement left
//					turnDone_in = 1'b1;
//					end
//
//				end
//
//				4'b0001: // s = down
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					tempYdown_in = DrawY + 10'd60;
//					
//					if(tempYdown > 10'd449)
//					begin
//					Ball_Y_Motion_in = 10'd0;
//					turnDone_in = 1'b0;
//					end
//					
//					else
//					begin
//					Ball_Y_Motion_in = Ball_Y_Step; // move down
//					turnDone_in = 1'b1;
//					end
//
//				end
//
//				4'b0010: // d = right;
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					tempXright_in = DrawX + 10'd60;
//					
//					if(tempXright > 10'd619)
//					begin
//					Ball_X_Motion_in = 10'd0;
//					turnDone_in = 1'b0;
//					end
//					
//					else
//					begin
//					Ball_X_Motion_in = Ball_X_Step; // move right
//					turnDone_in = 1'b1;
//					end
//
//				end
//				
//				default:
//					begin
//					Ball_Y_Motion_in = 10'd0;
//					Ball_X_Motion_in = 10'd0;
//					turnDone_in = 1'b0;
//					end
//
//			endcase
//				
//            // Update the ball's position with its motion
//            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
//            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
//        end
//        
//        /**************************************************************************************
//            ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
//            Hidden Question #2/2:
//               Notice that Ball_Y_Pos is updated using Ball_Y_Motion. 
//              Will the new value of Ball_Y_Motion be used when Ball_Y_Pos is updated, or the old? 
//              What is the difference between writing
//                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;" and 
//                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;"?
//              How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
//              Give an answer in your Post-Lab.
//        **************************************************************************************/
//    end
//    
//    // Compute whether the pixel corresponds to ball or background
//    /* Since the multiplicants are required to be signed, we have to first cast them
//       from logic to int (signed by default) before they are multiplied. */
//    int DistX, DistY, Size;
//    assign DistX = DrawX - Ball_X_Pos;
//    assign DistY = DrawY - Ball_Y_Pos;
//    assign Size = Ball_Size;
//    always_comb begin
//        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
//            is_ball = 1'b1;
//        else
//            is_ball = 1'b0;
//        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
//           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
//           of the 12 available multipliers on the chip! */
//    end
//    
//endmodule







////-------------------------------------------------------------------------
////    Ball.sv                                                            --
////    Viral Mehta                                                        --
////    Spring 2005                                                        --
////                                                                       --
////    Modified by Stephen Kempf 03-01-2006                               --
////                              03-12-2007                               --
////    Translated by Joe Meng    07-07-2013                               --
////    Modified by Po-Han Huang  12-08-2017                               --
////    Spring 2018 Distribution                                           --
////                                                                       --
////    For use with ECE 385 Lab 8                                         --
////    UIUC ECE Department                                                --
////-------------------------------------------------------------------------
//
//
//module  ball ( input         Clk,                // 50 MHz clock
//                             Reset,              // Active-high reset signal
//                             frame_clk,			 // The clock indicating a new frame (~60Hz)
//					input	[3:0]	  button,
//               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
//               output logic  is_ball             // Whether current pixel belongs to ball or background
//              );
//    
//    parameter [9:0] Ball_X_Center = 10'd590;  // Center position on the X axis
//    parameter [9:0] Ball_Y_Center = 10'd360;  // Center position on the Y axis
//    parameter [9:0] Ball_X_Min = 10'd20;       // Leftmost point on the X axis
//    parameter [9:0] Ball_X_Max = 10'd619;     // Rightmost point on the X axis
//    parameter [9:0] Ball_Y_Min = 10'd30;       // Topmost point on the Y axis
//    parameter [9:0] Ball_Y_Max = 10'd449;     // Bottommost point on the Y axis
//    parameter [9:0] Ball_X_Step = 10'd60;      // Step size on the X axis changed from 1 to 10
//    parameter [9:0] Ball_Y_Step = 10'd60;      // Step size on the Y axis
//    parameter [9:0] Ball_Size = 10'd10;        // Ball size
//    
//    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
//    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
//	 
//	 
//	 logic [9:0] tempXleft, tempXright, tempYup, tempYdown;
//	 assign tempXleft = DrawX - 10'd60; 
//	 assign tempYup = DrawY - 10'd60;
//    assign tempXright = DrawX + 10'd60;
//	 assign tempYdown = DrawY + 10'd60;
//	 
//    //////// Do not modify the always_ff blocks. ////////
//    // Detect rising edge of frame_clk
//    logic frame_clk_delayed, frame_clk_rising_edge;
//    always_ff @ (posedge Clk) begin
//        frame_clk_delayed <= frame_clk;
//        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
//    end
//	 
//	 
//    // Update registers
//    always_ff @ (posedge Clk)
//    begin
//        if (Reset)
//        begin
//            Ball_X_Pos <= Ball_X_Center;
//            Ball_Y_Pos <= Ball_Y_Center;
//            Ball_X_Motion <= 10'd0;
//            Ball_Y_Motion <= Ball_Y_Step;
//        end
//        else
//        begin
//            Ball_X_Pos <= Ball_X_Pos_in;
//            Ball_Y_Pos <= Ball_Y_Pos_in;
//            Ball_X_Motion <= Ball_X_Motion_in; 
//            Ball_Y_Motion <= Ball_Y_Motion_in;
//        end
//    end
//    //////// Do not modify the always_ff blocks. ////////
//    
//    // You need to modify always_comb block.
//    always_comb
//    begin
//        // By default, keep motion and position unchanged
//        Ball_X_Pos_in = Ball_X_Pos;
//        Ball_Y_Pos_in = Ball_Y_Pos;
//        Ball_X_Motion_in = Ball_X_Motion;
//        Ball_Y_Motion_in = Ball_Y_Motion; //change from Ball_?_Motion;
//        
//        // Update position and motion only at rising edge of frame clock
//        if (frame_clk_rising_edge)
//        begin
//		  
//		  case(button)
//						
//						
//				4'b1000: // w = Up
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//				
//					if(tempYup < 10'd55)
//					begin
//						Ball_Y_Motion_in = 10'd0;
//					end
//					
//					else
//					begin
//					Ball_Y_Motion_in = ~(Ball_Y_Step) + 1'b1; // 2's complement up
//					end
//
//				end
//
//				4'b0100: // a = left
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					if(tempXleft < 10'd35)
//					begin
//					Ball_X_Motion_in = 10'd0;
//					end
//					
//					else
//					begin
//					Ball_X_Motion_in = ~(Ball_X_Step) + 1'b1; // 2's complement left
//					end
//
//				end
//
//				4'b0001: // s = down
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					
//					if(tempYdown > 10'd449)
//					begin
//					Ball_Y_Motion_in = 10'd0;
//					end
//					
//					else
//					begin
//					Ball_Y_Motion_in = Ball_Y_Step; // move down
//					end
//
//				end
//
//				4'b0010: // d = right;
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					if(tempXright > 10'd619)
//					begin
//					Ball_X_Motion_in = 10'd0;
//					end
//					
//					else
//					begin
//					Ball_X_Motion_in = Ball_X_Step; // move right
//					end
//
//				end
//				
//				default:
//					begin
//					Ball_Y_Motion_in = 10'd0;
//					Ball_X_Motion_in = 10'd0;
//					end
//
//			endcase
//				
//            // Update the ball's position with its motion
//            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
//            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
//        end
//        
//        /**************************************************************************************
//            ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
//            Hidden Question #2/2:
//               Notice that Ball_Y_Pos is updated using Ball_Y_Motion. 
//              Will the new value of Ball_Y_Motion be used when Ball_Y_Pos is updated, or the old? 
//              What is the difference between writing
//                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;" and 
//                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;"?
//              How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
//              Give an answer in your Post-Lab.
//        **************************************************************************************/
//    end
//    
//    // Compute whether the pixel corresponds to ball or background
//    /* Since the multiplicants are required to be signed, we have to first cast them
//       from logic to int (signed by default) before they are multiplied. */
//    int DistX, DistY, Size;
//    assign DistX = DrawX - Ball_X_Pos;
//    assign DistY = DrawY - Ball_Y_Pos;
//    assign Size = Ball_Size;
//    always_comb begin
//        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
//            is_ball = 1'b1;
//        else
//            is_ball = 1'b0;
//        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
//           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
//           of the 12 available multipliers on the chip! */
//    end
//    
//endmodule












////-------------------------------------------------------------------------
////    Ball.sv                                                            --
////    Viral Mehta                                                        --
////    Spring 2005                                                        --
////                                                                       --
////    Modified by Stephen Kempf 03-01-2006                               --
////                              03-12-2007                               --
////    Translated by Joe Meng    07-07-2013                               --
////    Modified by Po-Han Huang  12-08-2017                               --
////    Spring 2018 Distribution                                           --
////                                                                       --
////    For use with ECE 385 Lab 8                                         --
////    UIUC ECE Department                                                --
////-------------------------------------------------------------------------
//
//
//module  ball ( input         Clk,                // 50 MHz clock
//                             Reset,              // Active-high reset signal
//                             frame_clk,			 // The clock indicating a new frame (~60Hz)
//					input	[3:0]	  button,
//               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
//               output logic  is_ball             // Whether current pixel belongs to ball or background
//              );
//    
//    parameter [9:0] Ball_X_Center = 10'd590;  // Center position on the X axis
//    parameter [9:0] Ball_Y_Center = 10'd360;  // Center position on the Y axis
//    parameter [9:0] Ball_X_Min = 10'd20;       // Leftmost point on the X axis
//    parameter [9:0] Ball_X_Max = 10'd619;     // Rightmost point on the X axis
//    parameter [9:0] Ball_Y_Min = 10'd30;       // Topmost point on the Y axis
//    parameter [9:0] Ball_Y_Max = 10'd449;     // Bottommost point on the Y axis
//    parameter [9:0] Ball_X_Step = 10'd60;      // Step size on the X axis changed from 1 to 10
//    parameter [9:0] Ball_Y_Step = 10'd60;      // Step size on the Y axis
//    parameter [9:0] Ball_Size = 10'd10;        // Ball size
//    
//    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
//    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
//    
//    //////// Do not modify the always_ff blocks. ////////
//    // Detect rising edge of frame_clk
//    logic frame_clk_delayed, frame_clk_rising_edge;
//    always_ff @ (posedge Clk) begin
//        frame_clk_delayed <= frame_clk;
//        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
//    end
//	 
//	 
//    // Update registers
//    always_ff @ (posedge Clk)
//    begin
//        if (Reset)
//        begin
//            Ball_X_Pos <= Ball_X_Center;
//            Ball_Y_Pos <= Ball_Y_Center;
//            Ball_X_Motion <= 10'd0;
//            Ball_Y_Motion <= Ball_Y_Step;
//        end
//        else
//        begin
//            Ball_X_Pos <= Ball_X_Pos_in;
//            Ball_Y_Pos <= Ball_Y_Pos_in;
//            Ball_X_Motion <= Ball_X_Motion_in; 
//            Ball_Y_Motion <= Ball_Y_Motion_in;
//        end
//    end
//    //////// Do not modify the always_ff blocks. ////////
//    
//    // You need to modify always_comb block.
//    always_comb
//    begin
//        // By default, keep motion and position unchanged
//        Ball_X_Pos_in = Ball_X_Pos;
//        Ball_Y_Pos_in = Ball_Y_Pos;
//        Ball_X_Motion_in = Ball_X_Motion;
//        Ball_Y_Motion_in = Ball_Y_Motion; //change from Ball_?_Motion;
//        
//        // Update position and motion only at rising edge of frame clock
//        if (frame_clk_rising_edge)
//        begin
//		  
//		  case(button)
//						
//						
//				4'b1000: // w = Up
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					//Ball_Y_Motion_in = ~(Ball_Y_Step) + 1'b1; // 2's complement up
//					Ball_Y_Motion_in = ~(Ball_Y_Step);
//				end
//
//				4'b0100: // a = left
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					//Ball_X_Motion_in = ~(Ball_X_Step) + 1'b1; // 2's complement left
//					Ball_X_Motion_in = ~(Ball_X_Step);
//
//				end
//
//				4'b0001: // s = down
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = Ball_Y_Step; // move down
//
//				end
//
//				4'b0010: // d = right;
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = Ball_X_Step; // move right
//
//				end
//				
//				default:
//					begin
//					Ball_Y_Motion_in = 10'd0;
//					Ball_X_Motion_in = 10'd0;
//					end
//
//			endcase
//			
//            // Be careful when using comparators with "logic" datatype because compiler treats 
//            //   both sides of the operator as UNSIGNED numbers.
//            // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
//            // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
//				
//            if( Ball_Y_Pos + Ball_Size + Ball_Y_Motion_in >= Ball_Y_Max) 	// Ball is at the bottom edge, BOUNCE!
//					 begin
//                //Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);//changed from (~(Ball_Y_Step) + 1'b1);// 2's complement.
//					 Ball_X_Motion_in = 10'd0;
//					 Ball_Y_Motion_in = 10'd0;
//					 end
//					 
//            else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size + Ball_Y_Motion_in)  // Ball is at the top edge, BOUNCE!
//						begin
//						//Ball_Y_Motion_in  = Ball_Y_Step; // changed from Ball_Y_Step; //add 1?
//						Ball_X_Motion_in = 10'd0;
//						Ball_Y_Motion_in = 10'd0;
//						end
//				else	 
//				
//				if( Ball_X_Pos + Ball_Size + Ball_X_Motion_in >= Ball_X_Max)  // Ball is at the right edge, BOUNCE!
//					 begin
//                //Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1); // 2's complement. Changed from (~(Ball_X_Step) + 1'b1)
//					 Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 end
//            else if ( Ball_X_Pos <= Ball_X_Min + Ball_Size + Ball_X_Motion_in)  // Ball is at the left edge, BOUNCE!   Don't move!!! //add step?
//					 begin
//                //Ball_X_Motion_in = Ball_X_Step; //changed from Ball_X_Step
//					 Ball_Y_Motion_in = 10'd0;
//					 Ball_X_Motion_in = 10'd0;
//					 end
//					 
//            // TODO: Add other boundary detections and handle keypress here.
//	
//				
//            // Update the ball's position with its motion
//            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
//            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
//        end
//        
//        /**************************************************************************************
//            ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
//            Hidden Question #2/2:
//               Notice that Ball_Y_Pos is updated using Ball_Y_Motion. 
//              Will the new value of Ball_Y_Motion be used when Ball_Y_Pos is updated, or the old? 
//              What is the difference between writing
//                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;" and 
//                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;"?
//              How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
//              Give an answer in your Post-Lab.
//        **************************************************************************************/
//    end
//    
//    // Compute whether the pixel corresponds to ball or background
//    /* Since the multiplicants are required to be signed, we have to first cast them
//       from logic to int (signed by default) before they are multiplied. */
//    int DistX, DistY, Size;
//    assign DistX = DrawX - Ball_X_Pos;
//    assign DistY = DrawY - Ball_Y_Pos;
//    assign Size = Ball_Size;
//    always_comb begin
//        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
//            is_ball = 1'b1;
//        else
//            is_ball = 1'b0;
//        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
//           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
//           of the 12 available multipliers on the chip! */
//    end
//    
//endmodule




////-------------------------------------------------------------------------
////    Ball.sv                                                            --
////    Viral Mehta                                                        --
////    Spring 2005                                                        --
////                                                                       --
////    Modified by Stephen Kempf 03-01-2006                               --
////                              03-12-2007                               --
////    Translated by Joe Meng    07-07-2013                               --
////    Modified by Po-Han Huang  12-08-2017                               --
////    Spring 2018 Distribution                                           --
////                                                                       --
////    For use with ECE 385 Lab 8                                         --
////    UIUC ECE Department                                                --
////-------------------------------------------------------------------------
//
//
//module  ball ( input         Clk,                // 50 MHz clock
//                             Reset,              // Active-high reset signal
//                             frame_clk,			 // The clock indicating a new frame (~60Hz)
//					input	[3:0]	  button,
//               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
//               output logic  is_ball             // Whether current pixel belongs to ball or background
//              );
//    
//    parameter [9:0] Ball_X_Center = 10'd320;  // Center position on the X axis
//    parameter [9:0] Ball_Y_Center = 10'd240;  // Center position on the Y axis
//    parameter [9:0] Ball_X_Min = 10'd0;       // Leftmost point on the X axis
//    parameter [9:0] Ball_X_Max = 10'd639;     // Rightmost point on the X axis
//    parameter [9:0] Ball_Y_Min = 10'd0;       // Topmost point on the Y axis
//    parameter [9:0] Ball_Y_Max = 10'd479;     // Bottommost point on the Y axis
//    parameter [9:0] Ball_X_Step = 10'd10;      // Step size on the X axis changed from 1 to 10
//    parameter [9:0] Ball_Y_Step = 10'd10;      // Step size on the Y axis
//    parameter [9:0] Ball_Size = 10'd10;        // Ball size
//    
//    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
//    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
//    
//    //////// Do not modify the always_ff blocks. ////////
//    // Detect rising edge of frame_clk
//    logic frame_clk_delayed, frame_clk_rising_edge;
//    always_ff @ (posedge Clk) begin
//        frame_clk_delayed <= frame_clk;
//        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
//    end
//	 
//	 
//    // Update registers
//    always_ff @ (posedge Clk)
//    begin
//        if (Reset)
//        begin
//            Ball_X_Pos <= Ball_X_Center;
//            Ball_Y_Pos <= Ball_Y_Center;
//            Ball_X_Motion <= 10'd0;
//            Ball_Y_Motion <= Ball_Y_Step;
//        end
//        else
//        begin
//            Ball_X_Pos <= Ball_X_Pos_in;
//            Ball_Y_Pos <= Ball_Y_Pos_in;
//            Ball_X_Motion <= Ball_X_Motion_in; 
//            Ball_Y_Motion <= Ball_Y_Motion_in;
//        end
//    end
//    //////// Do not modify the always_ff blocks. ////////
//    
//    // You need to modify always_comb block.
//    always_comb
//    begin
//        // By default, keep motion and position unchanged
//        Ball_X_Pos_in = Ball_X_Pos;
//        Ball_Y_Pos_in = Ball_Y_Pos;
//        Ball_X_Motion_in = Ball_X_Motion;
//        Ball_Y_Motion_in = Ball_Y_Motion; //change from Ball_?_Motion;
//        
//        // Update position and motion only at rising edge of frame clock
//        if (frame_clk_rising_edge)
//        begin
//            // Be careful when using comparators with "logic" datatype because compiler treats 
//            //   both sides of the operator as UNSIGNED numbers.
//            // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
//            // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
//				
//            if( Ball_Y_Pos + Ball_Size + Ball_Y_Step >= Ball_Y_Max) 	// Ball is at the bottom edge, BOUNCE!
//					 begin
//                Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);//changed from (~(Ball_Y_Step) + 1'b1);// 2's complement.
//					 Ball_X_Motion_in = 10'd0;
//					 end
//					 
//            else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size + Ball_Y_Step)  // Ball is at the top edge, BOUNCE!
//						begin
//						Ball_Y_Motion_in  = Ball_Y_Step; // changed from Ball_Y_Step; //add 1?
//						Ball_X_Motion_in = 10'd0;
//						end
//				else	 
//				
//				if( Ball_X_Pos + Ball_Size + Ball_X_Step >= Ball_X_Max)  // Ball is at the right edge, BOUNCE!
//					 begin
//                Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1); // 2's complement. Changed from (~(Ball_X_Step) + 1'b1)
//					 Ball_Y_Motion_in = 10'd0;
//					 end
//            else if ( Ball_X_Pos <= Ball_X_Min + Ball_Size + Ball_X_Step)  // Ball is at the left edge, BOUNCE!   Don't move!!! //add step?
//					 begin
//                Ball_X_Motion_in = Ball_X_Step; //changed from Ball_X_Step
//					 Ball_Y_Motion_in = 10'd0;
//					 end
//					 
//            // TODO: Add other boundary detections and handle keypress here.
//				else 
//				
//				
//				begin
//				case(button)
//						
//						
//				4'b1000: // w = Up
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = ~(Ball_Y_Step) + 1'b1; // 2's complement up
//				end
//
//				4'b0100: // a = left
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = ~(Ball_X_Step) + 1'b1; // 2's complement left
//
//				end
//
//				4'b0001: // s = down
//				begin
//					Ball_X_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_Y_Motion_in = Ball_Y_Step; // move down
//
//				end
//
//				4'b0010: // d = right;
//				begin
//					Ball_Y_Motion_in = 10'd0; // Do nothing in this dimension
//					Ball_X_Motion_in = Ball_X_Step; // move right
//
//				end
//				
//				default:
//					begin
//					Ball_Y_Motion_in = 10'd0;
//					Ball_X_Motion_in = 10'd0;
//					end
//
//			endcase
//
//		end		
//				
//            // Update the ball's position with its motion
//            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
//            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
//        end
//        
//        /**************************************************************************************
//            ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
//            Hidden Question #2/2:
//               Notice that Ball_Y_Pos is updated using Ball_Y_Motion. 
//              Will the new value of Ball_Y_Motion be used when Ball_Y_Pos is updated, or the old? 
//              What is the difference between writing
//                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;" and 
//                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;"?
//              How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
//              Give an answer in your Post-Lab.
//        **************************************************************************************/
//    end
//    
//    // Compute whether the pixel corresponds to ball or background
//    /* Since the multiplicants are required to be signed, we have to first cast them
//       from logic to int (signed by default) before they are multiplied. */
//    int DistX, DistY, Size;
//    assign DistX = DrawX - Ball_X_Pos;
//    assign DistY = DrawY - Ball_Y_Pos;
//    assign Size = Ball_Size;
//    always_comb begin
//        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
//            is_ball = 1'b1;
//        else
//            is_ball = 1'b0;
//        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
//           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
//           of the 12 available multipliers on the chip! */
//    end
//    
//endmodule
