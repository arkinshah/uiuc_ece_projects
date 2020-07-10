#include "keyboard.h"

/* modifier scan codes */
#define LSHIFT_PRESSED	0x2A
#define LSHIFT_RELEASED	0xAA
#define RSHIFT_PRESSED	0x36
#define RSHIFT_RELEASED	0xB6
#define LCTRL_PRESSED	0x1D
#define LCTRL_RELEASED	0x9D
#define CAPS			0x3A
#define BACK_SPACE		0x0E
#define LALT_PRESSED	0x38
#define LALT_RELEASED	0xB8
#define SPACE			0x39
#define ENTER			0x1C
#define TAB_PRESSSED	0x0F
/* used for ctrl+l command */
#define L_ASCII			0x26
#define C_ASCII			0x2E

/* changing terminals */
#define F1				0x3B
#define F2				0x3C
#define F3				0x3D

/* size of ascii tables */
#define SCAN_CODE_SIZE  47
#define ASCII_CODE_SIZE 47
#define SCREEN_WIDTH	80

/* # of spaces when tab is pressed */
#define TAB_SIZE		4

/* screen dim */
#define NUM_ROWS		25
#define NUM_COLS		80

/* modifier flags */
/* 0 - no pressed, 1 - pressed */
static int SHIFT;
static int CTRL;
static int ALT;
static int CAPS_ON;
static int32_t terminals[MAX_BOOT_NUM_SHELLS] = {0, -1, -1};

/* Scancodes from PS2 keyboard */
/* Scan code table has a 1:1 index relationship with the other tables */
/* Could just put into a 2D array, but I find this way is easier to read */
static uint8_t scan_codes[SCAN_CODE_SIZE] = {
	/* A-Z */
	0x1E, 0x30, 0x2E, 0x20, 0x12, 0x21, 0x22, 0x23, 0x017, 0x24,
	0x25, 0x26, 0x32, 0x31, 0x18, 0x19, 0x10, 0x13, 0x1F, 0x14, 
	0x16, 0x2F, 0x11, 0x2D, 0x15, 0x2C,
	/* 1,2,3,...,9,0*/
	0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B,
	/* symbols starts from ` ends with / symbol. Goes row by row */
	0x29, 0x0C, 0x0D, 0x1A, 0x1B, 0x2B, 0x27, 0x28, 0x33, 0x34,
	0x35
};

/* ascii characters without shift modifier */
static uint8_t lowercase_ascii_chars[ASCII_CODE_SIZE] = {
	/* lowercase a-z */
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 
	'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
	'u', 'v', 'w', 'x', 'y', 'z',
	/* numbers */
	'1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
	/* symbols without shift */
	'`', '-', '=', '[', ']', '\\', ';', '\'', ',', '.',
	'/',
};

/* ASCII for SHIFT modifier */
static uint8_t shift_ascii_chars[ASCII_CODE_SIZE] = {
	/* Uppercase A-Z */
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
	'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
	'U', 'V', 'W', 'X', 'Y', 'Z',
	/* 1,2, ..., 9, 0 Symbols */
	'!', '@', '#', '$', '%', '^', '&', '*', '(', ')',
	/* symbols with shift */
	'~','_', '+', '{', '}', '|', ':', '"', '<', '>', 
	'?' 
};

/* ASCII for CAPS modifier */
static uint8_t caps_ascii_chars[ASCII_CODE_SIZE] = {
	/* Uppercase A-Z */
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
	'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
	'U', 'V', 'W', 'X', 'Y', 'Z',
	/* numbers */
	'1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
	/* symbols without shift */
	'`', '-', '=', '[', ']', '\\', ';', '\'', ',', '.',
	'/',
};

/* ASCII for CAPS + SHIFT */
static uint8_t caps_shift_ascii_chars[ASCII_CODE_SIZE] ={
	/* lowercase a-z */
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 
	'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
	'u', 'v', 'w', 'x', 'y', 'z',
	/* 1,2, ..., 9, 0 Symbols */
	'!', '@', '#', '$', '%', '^', '&', '*', '(', ')',
	/* symbols with shift */
	'~','_', '+', '{', '}', '|', ':', '"', '<', '>', 
	'?' 
};

/* 
 * keyboard_init
 *   DESCRIPTION: Initialize keyboard.
 *   INPUTS: none
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: Writes to PIC registers.
 */
void keyboard_init(){
	
	/* Enable the IRQ for the keyboard on the 8259 PIC */
	enable_irq(KEYBOARD_IRQ);
	set_cursor(0, 0, 0);

	int i, j;
	/* clear keyboard buffer */
	for (j = 0; j < MAX_NUM_TERMINALS; j++){
		for (i = 0; i < KEYBOARD_MAX_SZ; i++)
			terminal_arr[j].keyboard_buffer[i] = '\0';

		terminal_arr[j].buffer_pos = 0;
		terminal_arr[j].screen_x = 0;
		terminal_arr[j].screen_y = 0;
		terminal_arr[j].enter_pressed = 0;
	}

	SHIFT = 0;
	ALT = 0;
	CTRL = 0;
	CAPS_ON = 0;
	//enter_pressed = 0;

	//current_index = 0;
}

/* 
 * keyboard_interrupt
 *   DESCRIPTION: handler will interpret scan codes and write to keyboard buffer.
 * 				  Keyboard buffer will be copied to the terminal buffer
 *   INPUTS: none
 *   OUTPUTS: Prints a character to the screen.
 *   RETURN VALUE: none
 *   SIDE EFFECTS: Modifies video memory.
 */
void keyboard_interrupt(){
	
	/* Send End Of Interrupt to indicate that interrupt is handled */
	send_eoi(KEYBOARD_IRQ);
	cli();
	
	int i;
	/* Get scancode from keyboard */
	uint8_t code = inb(KEYBOARD_DATA);

	/* current terminal # */
	int cur_term = get_cur_terminal() - 1;

	int32_t current_index = terminal_arr[cur_term].buffer_pos;

	/* check if scan code is a modifier */
	switch(code){
		case LSHIFT_PRESSED:
		case RSHIFT_PRESSED:	
			SHIFT = 1;
			break;
		case LSHIFT_RELEASED:
		case RSHIFT_RELEASED:
			SHIFT = 0;
			break;
		case LCTRL_PRESSED:
			CTRL = 1;
			break;
		case LCTRL_RELEASED:
			CTRL = 0;
			break;
		case LALT_PRESSED:
			ALT = 1;
			break;
		case LALT_RELEASED:
			ALT = 0;
			break;
		case CAPS:
			/* if caps was already on and pressed again, turns it off */
			if (CAPS_ON == 1)
				CAPS_ON = 0;
			else
				CAPS_ON = 1;
			break;
	}	

	/* fill keyboard buffer with readable ascii chars */

	/* handler modifiers first */
	if (CTRL && code == L_ASCII)
		ctrl_l();
		
	else if (code == SPACE)
		space();

	else if (CTRL && code == C_ASCII)
		ctrl_c();

	/* enter ends typing */
	else if (code == ENTER)
		enter();

	else if(code == TAB_PRESSSED)
		tab();

	else if (code == BACK_SPACE)
		backspace();

	else if (ALT && code == F1)
		alt_fn(1);
	else if (ALT && code == F2)
		alt_fn(2);
	else if (ALT && code == F3)
		alt_fn(3);

	/* handle ascii char */
	/*****terminal_putc for now so we can see what we're typing *****/	
	else{
		/* check if it is in our table */
		for (i = 0; i < SCAN_CODE_SIZE; i++){
				/* Don't put more characters at 127 unless it's newline */
				if (current_index == KEYBOARD_MAX_SZ - 1 || current_index < 0){
					terminal_arr[cur_term].buffer_pos = current_index;
					return;
				}

				/* handle shift & caps modifier */
				if (CAPS_ON == 1 && SHIFT == 1){
					if (code == scan_codes[i]){
						terminal_arr[cur_term].keyboard_buffer[current_index] = caps_shift_ascii_chars[i];
						terminal_arr[cur_term].buffer_pos++;
						terminal_putc(cur_term+1, (char *)VIDMEM, caps_shift_ascii_chars[i]);
					}
				}
				/* handles CAPS modifier */
				else if (CAPS_ON == 1 && SHIFT == 0){
					if (code == scan_codes[i]){
						terminal_arr[cur_term].keyboard_buffer[current_index] = caps_ascii_chars[i];
						terminal_arr[cur_term].buffer_pos++;
						terminal_putc(cur_term+1, (char *)VIDMEM, caps_ascii_chars[i]);
					}
				}
				/* handles SHIFT modifier */
				else if (SHIFT == 1 && CAPS_ON == 0){
					if (code == scan_codes[i]){
						terminal_arr[cur_term].keyboard_buffer[current_index] = shift_ascii_chars[i];
						terminal_arr[cur_term].buffer_pos++;
						terminal_putc(cur_term+1, (char *)VIDMEM, shift_ascii_chars[i]);
					}
				}
				/* no modifiers */
				else if (SHIFT == 0 && CAPS_ON == 0){
					if (code == scan_codes[i]){
						terminal_arr[cur_term].keyboard_buffer[current_index] = lowercase_ascii_chars[i];
						terminal_arr[cur_term].buffer_pos++;
						terminal_putc(cur_term+1, (char *)VIDMEM, lowercase_ascii_chars[i]);
					}
				} 
				
				/* invalid scancode if not in our scancode table */
				else{
					printf("Invalid Scancode!\n");
					terminal_arr[cur_term].buffer_pos = current_index;
					return;
				}
		}
	}
}

/* ctrl_l
 *	DESCRIPTION: clears the screen and sets the cursor to the top after pressing ctrl+l
 *	INPUT: none
 *	OUTPUT: none
 *	RETURN VALUE: none
 *	SIDE_EFFECT: clear screen and places cursor to top
 */
void ctrl_l(){
	clear();
	//set_cursor(0,0);
	int i;
	
	int cur_term = get_cur_terminal() - 1;
	/* print current buffer 
	for (i = 0; i < current_index; i++){
		terminal_putc(cur_term+1, keyboard_buffer[i]);
		set_cursor(get_screen_x(), get_screen_y());
	}
	*/
	
	/* clear current buffer */
	for(i = 0; i < terminal_arr[cur_term].buffer_pos; i++)
		terminal_arr[cur_term].keyboard_buffer[i] = '\0';

	/* reset the current index = 0 */
	//current_index = 0;
	terminal_arr[cur_term].buffer_pos = 0;
	terminal_arr[cur_term].screen_x = 0;
	terminal_arr[cur_term].screen_y = 0;
	set_cursor_helper(0,0);

	// const int8_t *buf = "391OS> "; 
	// terminal_write(0, buf, strlen(buf));
	set_cursor_helper(get_screen_x(get_cur_terminal()), 0);
}

/* ctrl_c
 *	DESCRIPTION: halts current process by moving halt number (1) into eax, and pushing
				 256 ret_val to stack
 *	INPUT: none
 *	OUTPUT: none
 *	RETURN VALUE: none
 *	SIDE_EFFECT: returns to parent process
 */

// USING THIS DOES NOT HALT WHAT IS CURRENTLY ON SCREEN, HALTS PROGRAMS IN THE ORDER HANDLED BY SCHEDULER // 
void ctrl_c(){
	asm volatile("						\
				movl	$1, %eax		;\
				movl	$256, %ebx		;\
				int		$0x80			;\
	");
}

/* backspace
 *	DESCRIPTION: deletes the current index of keyboard buffer and decrements index by 1
 *	INPUT: none
 *	OUTPUT: none
 *	RETURN VALUE: none
 *	SIDE EFFECT: moves cursor and changes keyboard buffer
 */
void backspace(){

	/* current terminal # */
	int32_t cur_term = get_cur_terminal() - 1;

	if(terminal_arr[cur_term].buffer_pos == 0 || (get_screen_x(get_cur_terminal()) == 0 && get_screen_y(get_cur_terminal()) == 0))
		return;

	terminal_arr[cur_term].buffer_pos--;
	terminal_arr[cur_term].keyboard_buffer[terminal_arr[cur_term].buffer_pos] = ' ';
	
	delete_char();
}


/* tab
 *	DESCRIPTION: adds TAB_SIZE(4) spaces to keyboard buffer
 *	INPUT: none
 *	OUTPUT: none
 *	RETURN VALUE: none
 *	SIDE EFFECT: changes keybaord buffer
 */
void tab(){
	int i;

	/* current terminal # */
	int cur_term = get_cur_terminal() - 1;

	for (i = 0; i < TAB_SIZE; i++){
		/* make sure that tabbing doesn't go over 128 */
		if (terminal_arr[cur_term].buffer_pos + 1 > 127)
			return;

		terminal_arr[cur_term].keyboard_buffer[terminal_arr[cur_term].buffer_pos] = ' ';
		terminal_arr[cur_term].buffer_pos++;

		terminal_putc(cur_term+1, (char *)VIDMEM, ' ');
		set_cursor(get_screen_x(get_cur_terminal()), get_screen_y(get_cur_terminal()), 1);
		set_cursor_helper(get_screen_x(get_cur_terminal()), get_screen_y(get_cur_terminal()));
	}
}

/* enter
 *	DESCIRIPTON: handles enter presses. changes enter flag for temrinal
 *	INPUT: none
 *	OUTPUT: none
 *	RETURN VALUE: none
 *	SIDE EFFECT: raises enter_press flag for terminal_read() 
 */
void enter(){
	/* current terminal # */
	int cur_term = get_cur_terminal() - 1;

	terminal_arr[cur_term].keyboard_buffer[terminal_arr[cur_term].buffer_pos] = '\n';
	if(get_screen_y(get_cur_terminal()) < NUM_ROWS - 1){
		terminal_putc(cur_term+1, (char *)VIDMEM, '\n');
		set_cursor(get_screen_x(get_cur_terminal()), get_screen_y(get_cur_terminal()), 1);
		set_cursor_helper(get_screen_x(get_cur_terminal()), get_screen_y(get_cur_terminal()));
	}
	else
		scroll(cur_term+1, (char *)VIDMEM);

	terminal_arr[cur_term].buffer_pos = 0;
	terminal_arr[cur_term].enter_pressed = 1;
	return;
}

/* space
 *	DESCRIPTION: handles space presses
 *	INPUT: none.
 *	OUTPUT: none
 *	RETURN VALUE: none
 * 	SIDE EFFECT: places ' ' char onto screen
 */
void space(){

	/* current terminal # */
	int cur_term = get_cur_terminal() - 1;

	/* Don't put more characters at 127 unless it's newline */
	if (terminal_arr[cur_term].buffer_pos == KEYBOARD_MAX_SZ - 1)
		return;

	terminal_arr[cur_term].keyboard_buffer[terminal_arr[cur_term].buffer_pos] = ' ';
	terminal_arr[cur_term].buffer_pos++;
	
	terminal_putc(cur_term+1, (char *)VIDMEM, ' ');
	set_cursor(get_screen_x(get_cur_terminal()), get_screen_y(get_cur_terminal()), 1);
	set_cursor_helper(get_screen_x(get_cur_terminal()), get_screen_y(get_cur_terminal()));
}


/* alt_fn
 *	DESCRIPTION: handles terminal changing. If pressed for the first time, it spawns a shell, otherwise
 *				 it makes respective terminal the active terminal
 *	INPUT: num - terminal number to make active
 *	OUTPUT: none
 *	RETURN VALUE: none
 *	SIDE EFFECT: changes video memory and active terminals
 */
void alt_fn(int32_t num){

	//NOTE: need a cli over here
	cli();
	if(get_cur_terminal() == num){
		sti();
		return;
	}

	if(terminals[num-1] == -1){

		if (get_available_pid() == -1){
			terminal_write(0, "\nMax processes reached\n", 24);
			const int8_t *buf = "391OS> "; 
			terminal_write(0, buf, strlen(buf));
			sti();
			return;
		}


		int32_t ESP = -1;
		int32_t EBP = -1;
		// cli();
		terminals[num-1] = num-1;
		//set_cur_terminal(num);

		//NOTE: Should'nt this change set_cur_terminal and not cur_terminal_runnning (Fixed)
		set_cur_terminal_running(num);


		asm volatile("                  \
					movl %%esp, %0; \
					movl %%ebp, %1"\
    			: "=g" (ESP), "=g" (EBP)
    			:
    			: "cc", "esp", "ebp"
    			);
		cur_pcb->esp = ESP;
		cur_pcb->ebp = EBP;
		execute((uint8_t*)"shell");
		sti(); // Program never reaches here
	}

	make_terminal_active(num);
	// sti();
}

void set_terminals(int32_t index, int32_t value){
	if(index >= MAX_BOOT_NUM_SHELLS){return;}
	terminals[index] = value;
}

int32_t get_terminals(int32_t index){
	if(index >= MAX_BOOT_NUM_SHELLS){return -1;}
	return terminals[index];
}

