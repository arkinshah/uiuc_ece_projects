//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input              is_ball, is_mum,           // Whether current pixel belongs to ball
                                                              //   or background (computed in ball.sv)
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );

    logic [7:0] Red, Green, Blue;

    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;

    // Assign color based on is_ball signal
    always_comb
    begin
        if (is_ball == 1'b1)
        begin
            // White ball
            Red = 8'hff;
            Green = 8'hff;
            Blue = 8'hff;
        end
		  
		  
		 else if (is_mum == 1'b1)
		  begin
		  Red = 8'h00;
        Green = 8'h00;
        Blue = 8'h00;
		  end
		  
        else
        begin


 ////// GOLDEN GOAL ///////////

		  if(DrawX >= 10'd116 && DrawX <= 10'd166 && DrawY < 10'd36)
        begin
        Red = 8'hda;
        Green = 8'ha5;
        Blue = 8'h20;
        end
		  
		  
		  //////////////// PURPLE WALLS ///////////////////
		  
		  else if(DrawX >= 10'd191 && DrawX <= 10'd268 && DrawY >= 10'd102 && DrawY <= 10'd122)
				begin
				Red = 8'h80;
				Green = 8'h00;
				Blue = 8'h80;
				end
				
	     else if(DrawX >= 10'd191 && DrawX <= 10'd211 && DrawY >= 10'd102 && DrawY <= 10'd188)
				begin
				Red = 8'h80;
				Green = 8'h00;
				Blue = 8'h80;
				end
				
				/*********** END OF WALL 1 CODE ***************/
			
		  else if(DrawX >= 10'd218 && DrawX <= 10'd319 && DrawY >=10'd255 && DrawY <= 10'd275)
				begin
				Red = 8'h80;
				Green = 8'h00;
				Blue = 8'h80;
				end
			
				/*********** END OF WALL 2 CODE ***************/
				
			else if(DrawX >= 10'd172 && DrawX <= 10'd192 && DrawY >= 10'd342 && DrawY <= 10'd392)
				begin
				Red = 8'h80;
				Green = 8'h00;
				Blue = 8'h80;
				end
			 
			   /*********** END OF WALL 3 CODE ***************/ 
				
			else if(DrawX >= 10'd422 && DrawX <= 10'd523 && DrawY >=10'd143 && DrawY <= 10'd163)
				begin
				Red = 8'h80;
				Green = 8'h00;
				Blue = 8'h80;
				end
			
				/*********** END OF WALL 4 CODE ***************/
				
			else if(DrawX >= 10'd437 && DrawX <= 10'd457 && DrawY >=10'd240 && DrawY <= 10'd290)
				begin
				Red = 8'h80;
				Green = 8'h00;
				Blue = 8'h80;
				end	
				
			  /*********** END OF WALL 5 CODE ***************/
		  

				////////////////   Column 1  ///////////////

				else if(DrawX >= 10'd116 && DrawX <= 10'd166 && DrawY >=10'd36 && DrawY <= 10'd86)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				else if(DrawX >= 10'd116 && DrawX <= 10'd166 && DrawY >=10'd138 && DrawY <= 10'd188)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				else if(DrawX >= 10'd116 && DrawX <= 10'd166 && DrawY >=10'd240 && DrawY <= 10'd290)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				else if(DrawX >= 10'd116 && DrawX <= 10'd166 && DrawY >=10'd342 && DrawY <= 10'd392)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				//////////// COLUMN 2 ////////////////

				else if(DrawX >= 10'd167 && DrawX <= 10'd217 && DrawY >= 10'd87 && DrawY <= 10'd137)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				else if(DrawX >= 10'd167 && DrawX <= 10'd217 && DrawY >= 10'd189 && DrawY <= 10'd239)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				else if(DrawX >= 10'd167 && DrawX <= 10'd217 && DrawY >= 10'd291 && DrawY <= 10'd341)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end
				
				else if(DrawX >= 10'd167 && DrawX <= 10'd217 && DrawY >= 10'd393 && DrawY <= 10'd443)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end


				////////////// COLUMN 3 /////////////

				else if(DrawX >= 10'd218 && DrawX <= 10'd268 && DrawY >=10'd36 && DrawY <= 10'd86)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				else if(DrawX >= 10'd218 && DrawX <= 10'd268 && DrawY >=10'd138 && DrawY <= 10'd188)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				else if(DrawX >= 10'd218 && DrawX <= 10'd268 && DrawY >=10'd240 && DrawY <= 10'd290)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				else if(DrawX >= 10'd218 && DrawX <= 10'd268 && DrawY >=10'd342 && DrawY <= 10'd392)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

                //////////// COLUMN 4 ////////////////

				else if(DrawX >= 10'd269 && DrawX <= 10'd319 && DrawY >= 10'd87 && DrawY <= 10'd137)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				else if(DrawX >= 10'd269 && DrawX <= 10'd319 && DrawY >= 10'd189 && DrawY <= 10'd239)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				else if(DrawX >= 10'd269 && DrawX <= 10'd319 && DrawY >= 10'd291 && DrawY <= 10'd341)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end
				
				else if(DrawX >= 10'd269 && DrawX <= 10'd319 && DrawY >= 10'd393 && DrawY <= 10'd443)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				////////////// COLUMN 5 ///////////////////

				else if(DrawX >= 10'd320 && DrawX <= 10'd370 && DrawY >=10'd36 && DrawY <= 10'd86)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				else if(DrawX >= 10'd320 && DrawX <= 10'd370 && DrawY >=10'd138 && DrawY <= 10'd188)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				else if(DrawX >= 10'd320 && DrawX <= 10'd370 && DrawY >=10'd240 && DrawY <= 10'd290)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				else if(DrawX >= 10'd320 && DrawX <= 10'd370 && DrawY >=10'd342 && DrawY <= 10'd392)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

        //////////// COLUMN 6 ////////////////

				else if(DrawX >= 10'd371 && DrawX <= 10'd421 && DrawY >= 10'd87 && DrawY <= 10'd137)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				else if(DrawX >= 10'd371 && DrawX <= 10'd421 && DrawY >= 10'd189 && DrawY <= 10'd239)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				else if(DrawX >= 10'd371 && DrawX <= 10'd421 && DrawY >= 10'd291 && DrawY <= 10'd341)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end
				
				else if(DrawX >= 10'd371 && DrawX <= 10'd421 && DrawY >= 10'd393 && DrawY <= 10'd443)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				//////////////// COLUMN 7 ////////////////

				else if(DrawX >= 10'd422 && DrawX <= 10'd472 && DrawY >=10'd36 && DrawY <= 10'd86)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				else if(DrawX >= 10'd422 && DrawX <= 10'd472 && DrawY >=10'd138 && DrawY <= 10'd188)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				else if(DrawX >= 10'd422 && DrawX <= 10'd472 && DrawY >=10'd240 && DrawY <= 10'd290)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				else if(DrawX >= 10'd422 && DrawX <= 10'd472 && DrawY >=10'd342 && DrawY <= 10'd392)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

        //////////// COLUMN 8 ////////////////

				else if(DrawX >= 10'd473 && DrawX <= 10'd523 && DrawY >= 10'd87 && DrawY <= 10'd137)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end 

				else if(DrawX >= 10'd473 && DrawX <= 10'd523 && DrawY >= 10'd189 && DrawY <= 10'd239)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				else if(DrawX >= 10'd473 && DrawX <= 10'd523 && DrawY >= 10'd291 && DrawY <= 10'd341)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end
				
				else if(DrawX >= 10'd473 && DrawX <= 10'd523 && DrawY >= 10'd393 && DrawY <= 10'd443)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end

				
				else if(DrawX >= 10'd473 && DrawX <= 10'd523 && DrawY >= 10'd393 && DrawY <= 10'd443)
				begin
				Red = 8'hff;
				Green = 8'hde;
				Blue = 8'had;
				end


        // BOUNDRIES

        else if(DrawX < 10'd116 || DrawX > 10'd523 || DrawY < 10'd36 || DrawY > 10'd443)
        begin
        Red = 8'h8b;
        Green = 8'h45;
        Blue = 8'h13;
        end

				///// DARK BROWN BLOCK ///////
				else
				begin
				Red = 8'hde;
				Green = 8'hb8;
				Blue = 8'h87;
				end

        end
    end

endmodule

//640 x 480
// x: 65-574, width = 51
// 0-64 // 65-115,// 116-166, 167-217, 218-268, 269-319, 320-370, 371-421, 422-472, 473-523,// 524-574 // 575-639
// y: 36-443
// 0-35 // 36-86, 87-137, 138-188, 189-239, 240-290, 291-341, 342-392, 393-443, // 444-479
//ODD: 4 (LIGHT), EVEN: 4 (DARK)
// 8 ROWS, 8 COLS