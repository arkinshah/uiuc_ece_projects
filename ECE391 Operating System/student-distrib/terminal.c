#include "terminal.h"
#include "keyboard.h"

int32_t magic_nums2[MAGIC_NUM_SIZE] = {MAGIC_NUM_1, MAGIC_NUM_2, MAGIC_NUM_3, MAGIC_NUM_4};

/* clear_screen_and_buffer
 *  DESCRIPTION: doesn't actually clear screen and buffer... essentially set_cursor
 *  INPUT: cursor_x - x position
 *         cursor_y - y position
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIDE EFFECT: changes cursor position
 */
void clear_screen_and_buffer(int32_t cursor_x, int32_t cursor_y){
	set_cursor(cursor_x,cursor_y, 1);
    set_cursor_helper(cursor_x,cursor_y);
	
}

/* terminal_open
 *  DESCRIPTION: nothing for now
 *  INPUT: filename - file to open
 *  OUTPUT: none
 *  RETURN VALUE: always 0
 *  SIDE EFFECT: none
 */
int32_t terminal_open(const uint8_t *filename){
    return 0;
}

/* terminal_close
 *  DESCRIPTION: nothing for now
 *  INPUT: fd - file descriptor
 *  OUTPUT: none
 *  RETURN VALUE: always 0
 *  SIDE EFFECT: none
 */
int32_t terminal_close(int32_t fd){
    return 0;
}

/* terminal_read
 *  DESCRIPTION: reads from the keyboard buffer into buf, return number of bytes
 *  INPUT: fd - file descriptor
 *         buf - buffer to write to
 *         nbytes - # bytes to read
 *  OUTPUT: none
 *  RETURN VALUES: -1 on failure, # bytes read on success
 *  SIDE EFFECT: none
 */
int32_t terminal_read(int32_t fd, void *buf, int32_t nbytes){

    if (buf == NULL)
        return -1;

    /* if the size of what were reading is larger than 127, scale down to 127 + newline */
    if (nbytes > KEYBOARD_MAX_SZ - 1)
        nbytes = KEYBOARD_MAX_SZ - 1;

    int cur_term = get_cur_terminal() - 1;

    /* wait for enter to be pressed */
    while(!terminal_arr[cur_term].enter_pressed);
    /* clear the flag so we can read from keyboard again */
    terminal_arr[cur_term].enter_pressed = 0;

    int i = 0, j = 0;

    /* copy keyboard buffer -> buf */
    for (i = 0; i < nbytes; i++){
        if(terminal_arr[get_cur_terminal() - 1].keyboard_buffer[i] == '\n'){
            ((uint8_t *)buf)[i] = '\n';
            i++;
            break;
        }
        /* copy ascii characters */
        ((uint8_t *)buf)[i] = terminal_arr[cur_term].keyboard_buffer[i];
    }

    /* null terminate */
    ((uint8_t *)buf)[i] = '\0';
    
    set_cursor(get_screen_x(get_cur_terminal()), get_screen_y(get_cur_terminal()), 1);
    set_cursor_helper(get_screen_x(get_cur_terminal()), get_screen_y(get_cur_terminal()));

    /* clear keyboard buffer after writing the buffer */
    for (j = 0; j < KEYBOARD_MAX_SZ; j++)
        terminal_arr[cur_term].keyboard_buffer[j] = '\0';

    return i;
}

/* terminal_write
 *  DESCRIPTION: writes to the screen from buf, return number of bytes written
 *  INPUT: fd - file descriptor
 *         buf - buffer to write to screen
 *         nbytes - number of bytes to write
 *  OUTPUT: keyboard buffer to screen
 *  RETURN VALUE: -1 on failure, nbytes on success
 *  SIDE EFFECT: write to screen
 */
int32_t terminal_write(int32_t fd, const void *buf, int32_t nbytes){
    //cli();
    /* check if buf == NULL or nbytes = 0 */
    if (buf == NULL){
        //sti();
        return -1;
    }
    //int32_t exe = 1;

    int i;

    /* Check if file is an executable */
    // for(i = 0; i < MAGIC_NUM_SIZE; i++)
    //     if(((int32_t *)buf)[i] != magic_nums2[i])
    //         exe = 0;
 
    int ret_val = nbytes;
    int cur_term_running = get_cur_terminal_running() - 1;
    //int cur_term_we_can_see = get_cur_terminal() - 1;

    /* write buf -> screen */
    for (i = 0; i < nbytes; i++){
        terminal_putc(cur_term_running+1, get_video_mem(), ((uint8_t*)buf)[i]);

        if (((uint8_t *)buf)[i] == '\0'){
            ret_val = i;
            // if (!exe){
            //     set_cursor(get_screen_x(get_cur_terminal_running()), get_screen_y(get_cur_terminal_running()), 0);
            //     return i;
            // }

        }
        
        set_cursor(get_screen_x(get_cur_terminal_running()), get_screen_y(get_cur_terminal_running()), 0);
    }
    
    //sti();
    return ret_val;
}


/* error_function_stdin_write
 *  DESCRIPTION: returns -1 (error) if someone tries to write from stdin
 *  INPUT: fd - file descriptor
 *         buf - buffer to write to screen
 *         nbytes - number of bytes to write
 *  OUTPUT: keyboard buffer to screen
 *  RETURN VALUE: -1 (always)
 *  SIDE EFFECT: none
 */
int32_t error_function_stdin_write(int32_t fd, const void *buf, int32_t nbytes){
    return -1;
}

/* error_function_stdout_read
 *  DESCRIPTION:  returns -1 (error) if someone tries to read from stdout
 *  INPUT: fd - file descriptor
 *         buf - buffer to write to
 *         nbytes - # bytes to read
 *  OUTPUT: none
 *  RETURN VALUES: -1 (always)
 *  SIDE EFFECT: none
 */
int32_t error_function_stdout_read(int32_t fd, void *buf, int32_t nbytes){
    return -1;
}


