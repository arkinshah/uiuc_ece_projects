/* lib.c - Some basic library functions (printf, strlen, etc.)
 * vim:ts=4 noexpandtab */

#include "lib.h"

#define VIDEO       0xB8000
#define NUM_COLS    80
#define NUM_ROWS    25
#define ATTRIB       0x7 // default grey
#define ATTRIB1      0xC // red
#define ATTRIB2      0x2 // green
#define ATTRIB3      0x3 // blue

/* Cursor values */
#define CURSOR_REG4 0x3D4
#define CURSOR_REG5 0x3D5
#define CURSOR_MASK 0xFF
#define WRITE_X     0x0F
#define WRITE_Y     0x0E

static int screen_x;
static int screen_y;
static char* video_mem = (char *)VIDEO;

static int32_t cur_terminal = 1;
static int32_t cur_terminal_running = 1;
//static char* video_mem_offscreen = (char *)VIDEO;

/* void clear(void);
 * Inputs: void
 * Return Value: none
 * Function: Clears video memory */
void clear(void) {
    int32_t i;
    for (i = 0; i < NUM_ROWS * NUM_COLS; i++) {
        *(uint8_t *)(VIDEO + (i << 1)) = ' ';
        *(uint8_t *)(VIDEO + (i << 1) + 1) = ATTRIB;
    }
}

/* scroll
 *  DESCRIPTION: scrolls the screen up 1 row and makes room for new row
 *  INPUT: none
 *  OUTPUT: none
 *  RETURN VALUES: none
 *  SIDE EFFECT: shifts video memory up 1 row
 */
void scroll(int32_t cur_term, char* vid_start){
    int32_t i, j;

    //int cur_term = get_cur_terminal_running();

    /* move old content up 1 row, leave bottom row (ROW-1) to assign later */
    for (i = 0; i < NUM_ROWS - 1; i++)
        for (j = 0; j < NUM_COLS; j++){
            // set current Row = next Row
            *(uint8_t *)(vid_start + ((i * NUM_COLS + j) << 1)) = *(uint8_t *)(vid_start + (((i+1)*NUM_COLS + j) << 1));
            
            /* select color depending on current terminal */
            if (cur_term == 1)
                *(uint8_t *)(vid_start + ((i * NUM_COLS + j) << 1) + 1) = ATTRIB1;
            else if (cur_term == 2)
                *(uint8_t *)(vid_start + ((i * NUM_COLS + j) << 1) + 1) = ATTRIB2;
            else if (cur_term == 3)
                *(uint8_t *)(vid_start + ((i * NUM_COLS + j) << 1) + 1) = ATTRIB3;
        }

    /* clear the new row */
    for (i = 0; i < NUM_COLS; i++){
        *(uint8_t *)(vid_start + (((NUM_ROWS - 1) * NUM_COLS + i) << 1)) = ' ';
        *(uint8_t *)(vid_start + (((NUM_ROWS - 1) * NUM_COLS + i) << 1) + 1) = ATTRIB;        
    }

    /* move cursor to bottom of screen */
    //set_cursor(0, get_screen_y());
    if(cur_term == get_cur_terminal()){
        set_cursor(0, NUM_ROWS-1, 1);
        set_cursor_helper(0, NUM_ROWS-1);
    }else{
        set_cursor(0, NUM_ROWS-1, 0);
    }
}

/* delete_char
 *  DESCRIPTION: deletes a character on the screen. Should only be allowed to erase keyboard buffer
 *               and not anything on the screen.
 *  INPUT: none
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIDE EFFECT: changes video memory
 */
void delete_char(){
    /* check edge of screen */
    if (terminal_arr[cur_terminal-1].screen_x == 0){
        terminal_arr[cur_terminal-1].screen_x = NUM_COLS - 1;
        terminal_arr[cur_terminal-1].screen_y--;
    }
    else
        terminal_arr[cur_terminal-1].screen_x--;
    
    /* delete the character AFTER screen_x */
    *(uint8_t *)(VIDEO + ((terminal_arr[cur_terminal-1].screen_y * NUM_COLS + terminal_arr[cur_terminal-1].screen_x) << 1)) = ' ';
    *(uint8_t *)(VIDEO + ((terminal_arr[cur_terminal-1].screen_y * NUM_COLS + terminal_arr[cur_terminal-1].screen_x) << 1) + 1) = ATTRIB;

    //set_cursor(terminal_arr[cur_terminal-1].screen_x, terminal_arr[cur_terminal-1].screen_y);
    set_cursor_helper(terminal_arr[cur_terminal-1].screen_x, terminal_arr[cur_terminal-1].screen_y);
}

/* set_cursor
 *  DESCRIPTION: sets cursor and screen position
 *  INPUT: x - x pos
 *         y - y pos
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIDE EFFECT: changes where typing starts
 */
void set_cursor(int x, int y, int32_t is_ter_displayed){

    int32_t cur_term = 0;

    if(is_ter_displayed){
        cur_term = cur_terminal;
    }else{
        cur_term = cur_terminal_running;
    }

    /* if we're at the edge of the screen, move down a row */
    if (terminal_arr[cur_term-1].screen_x >= NUM_COLS){
        terminal_arr[cur_term-1].screen_y++;
        terminal_arr[cur_term-1].screen_x = 0;
        if (terminal_arr[cur_term-1].screen_y >= NUM_ROWS){
            if(is_ter_displayed){
                scroll(cur_term, (char*)VIDEO);
            }else{
                scroll(cur_term, video_mem);
            }
            terminal_arr[cur_term-1].screen_y = NUM_ROWS - 1;
        }
    }
    else{
        /* screen_x should be 1 behind cursor */
        terminal_arr[cur_term-1].screen_x = x;
        /* cursor y pos should be same as screen_y */
        terminal_arr[cur_term-1].screen_y = y;
    }

    if(cur_terminal == cur_terminal_running){
        set_cursor_helper(x,y);
    }
}

/* set_cursor_helper
 *  DESCRIPTION: sends values to cursor data ports
 *  INTPUT: x - x position of cursor
 *          y - y position of cursor
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIDE EFFECT: changes cursor location
 */
void set_cursor_helper(int x, int y){
     uint16_t i = y * NUM_COLS + x;

    /* sending 0000 111A, where A = 0/1 depending on writing Y/X */
    outb(WRITE_X, CURSOR_REG4);
    /* Y is in upper byte, X is in lower byte */
    outb((uint8_t)i & CURSOR_MASK, CURSOR_REG5);

    /* shift by 8 to get higher byte */
    outb(WRITE_Y, CURSOR_REG4);
    outb((uint8_t)(i >> 8) & CURSOR_MASK, CURSOR_REG5);

}


/* get_screen_x
 *  DESCRIPTION: gets current screen_x value
 *  INPUT: none
 *  OUTPUT: none
 *  RETURN VALUE: screen_x
 *  SIDE EFFECT: none
 */
int get_screen_x(int32_t terminal){
    return terminal_arr[terminal-1].screen_x;
}

/* get_screen_y
 *  DESCRIPTION: gets current screen_y value
 *  INPUT: none
 *  OUTPUT: none
 *  RETURN VALUE: screen_y
 *  SIDE EFFECT: none
 */
int get_screen_y(int32_t terminal){
    return terminal_arr[terminal-1].screen_y;
}

/* set_screen_x
 *  DESCRIPTION: set current screen_x value
 *  INPUT: x - value to set
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIDE EFFECT: none
 */
void set_screen_x(int x){
    screen_x = x;
}

/* set_screen_y
 *  DESCRIPTION: set current screen_y value
 *  INPUT: y - value to set
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIDE EFFECT: none
 */
void set_screen_y(int y){
    screen_y = y;
}

/* Standard printf().
 * Only supports the following format strings:
 * %%  - print a literal '%' character
 * %x  - print a number in hexadecimal
 * %u  - print a number as an unsigned integer
 * %d  - print a number as a signed integer
 * %c  - print a character
 * %s  - print a string
 * %#x - print a number in 32-bit aligned hexadecimal, i.e.
 *       print 8 hexadecimal digits, zero-padded on the left.
 *       For example, the hex number "E" would be printed as
 *       "0000000E".
 *       Note: This is slightly different than the libc specification
 *       for the "#" modifier (this implementation doesn't add a "0x" at
 *       the beginning), but I think it's more flexible this way.
 *       Also note: %x is the only conversion specifier that can use
 *       the "#" modifier to alter output. */
int32_t printf(int8_t *format, ...) {

    /* Pointer to the format string */
    int8_t* buf = format;

    /* Stack pointer for the other parameters */
    int32_t* esp = (void *)&format;
    esp++;

    while (*buf != '\0') {
        switch (*buf) {
            case '%':
                {
                    int32_t alternate = 0;
                    buf++;

format_char_switch:
                    /* Conversion specifiers */
                    switch (*buf) {
                        /* Print a literal '%' character */
                        case '%':
                            putc('%');
                            break;

                        /* Use alternate formatting */
                        case '#':
                            alternate = 1;
                            buf++;
                            /* Yes, I know gotos are bad.  This is the
                             * most elegant and general way to do this,
                             * IMHO. */
                            goto format_char_switch;

                        /* Print a number in hexadecimal form */
                        case 'x':
                            {
                                int8_t conv_buf[64];
                                if (alternate == 0) {
                                    itoa(*((uint32_t *)esp), conv_buf, 16);
                                    puts(conv_buf);
                                } else {
                                    int32_t starting_index;
                                    int32_t i;
                                    itoa(*((uint32_t *)esp), &conv_buf[8], 16);
                                    i = starting_index = strlen(&conv_buf[8]);
                                    while(i < 8) {
                                        conv_buf[i] = '0';
                                        i++;
                                    }
                                    puts(&conv_buf[starting_index]);
                                }
                                esp++;
                            }
                            break;

                        /* Print a number in unsigned int form */
                        case 'u':
                            {
                                int8_t conv_buf[36];
                                itoa(*((uint32_t *)esp), conv_buf, 10);
                                puts(conv_buf);
                                esp++;
                            }
                            break;

                        /* Print a number in signed int form */
                        case 'd':
                            {
                                int8_t conv_buf[36];
                                int32_t value = *((int32_t *)esp);
                                if(value < 0) {
                                    conv_buf[0] = '-';
                                    itoa(-value, &conv_buf[1], 10);
                                } else {
                                    itoa(value, conv_buf, 10);
                                }
                                puts(conv_buf);
                                esp++;
                            }
                            break;

                        /* Print a single character */
                        case 'c':
                            putc((uint8_t) *((int32_t *)esp));
                            esp++;
                            break;

                        /* Print a NULL-terminated string */
                        case 's':
                            puts(*((int8_t **)esp));
                            esp++;
                            break;

                        default:
                            break;
                    }

                }
                break;

            default:
                putc(*buf);
                break;
        }
        buf++;
    }
    return (buf - format);
}

/* int32_t puts(int8_t* s);
 *   Inputs: int_8* s = pointer to a string of characters
 *   Return Value: Number of bytes written
 *    Function: Output a string to the console */
int32_t puts(int8_t* s) {
    register int32_t index = 0;
    while (s[index] != '\0') {
        putc(s[index]);
        index++;
    }
    return index;
}

/* void putc(uint8_t c);
 * Inputs: uint_8* c = character to print
 * Return Value: void
 *  Function: Output a character to the console */
void putc(uint8_t c) {
    if(c == '\n' || c == '\r') {
        screen_y++;
        screen_x = 0;
    } else {
        *(uint8_t *)(video_mem + ((NUM_COLS * screen_y + screen_x) << 1)) = c;
        *(uint8_t *)(video_mem + ((NUM_COLS * screen_y + screen_x) << 1) + 1) = ATTRIB;
        screen_x++;
        screen_x %= NUM_COLS;
        screen_y = (screen_y + (screen_x / NUM_COLS)) % NUM_ROWS;
    }
}

/* terminal_putc
 *  DESCRIPTION: prints character to terminal's memory space
 *  INPUT: term_num - terminal to print to
 *         vid_start - start of terminal's video memory
 *         c - character to print
 *  OUTPUT: characters to screen
 *  RETURN VALUE: none
 *  SIDE_EFFECT: prints to screen
 */
void terminal_putc(int term_num, char* vid_start, uint8_t c) {
    if (c == '\0')
        return;

    /* if newline at max row, scroll */
    if(c == '\n' || c == '\r') {
        terminal_arr[term_num-1].screen_x = 0;
        terminal_arr[term_num-1].screen_y++;
        
        if (terminal_arr[term_num-1].screen_y >= NUM_ROWS)
            scroll(term_num, vid_start);

    } else {
        *(uint8_t *)(vid_start + ((NUM_COLS * terminal_arr[term_num-1].screen_y + terminal_arr[term_num-1].screen_x) << 1)) = c;
        //*(uint8_t *)(video_mem + ((NUM_COLS * terminal_arr[term_num-1].screen_y + terminal_arr[term_num-1].screen_x) << 1) + 1) = ATTRIB1;

        /* depending on terminal number, change color of text */
        if (term_num == 1)
            *(uint8_t *)(vid_start + ((NUM_COLS * terminal_arr[term_num-1].screen_y + terminal_arr[term_num-1].screen_x) << 1) + 1) = ATTRIB1;
        else if (term_num == 2)
            *(uint8_t *)(vid_start + ((NUM_COLS * terminal_arr[term_num-1].screen_y + terminal_arr[term_num-1].screen_x) << 1) + 1) = ATTRIB2;
        else if (term_num == 3)
            *(uint8_t *)(vid_start + ((NUM_COLS * terminal_arr[term_num-1].screen_y + terminal_arr[term_num-1].screen_x) << 1) + 1) = ATTRIB3;

        terminal_arr[term_num-1].screen_x++;
        //screen_y = (screen_y + (screen_x / NUM_COLS)) % NUM_ROWS;
        terminal_arr[term_num-1].screen_y = (terminal_arr[term_num-1].screen_y + (terminal_arr[term_num-1].screen_x / NUM_COLS));

        /* handle scrolling of terminal */
        if (terminal_arr[term_num-1].screen_y >= NUM_ROWS){
            terminal_arr[term_num-1].screen_x = 0;
            terminal_arr[term_num-1].screen_y = NUM_ROWS - 1;
            scroll(term_num, vid_start);
        }
        else{
            terminal_arr[term_num-1].screen_x %= NUM_COLS;
            terminal_arr[term_num-1].screen_y %= NUM_ROWS;
        }
    }

    /* if we're on the same terminal, move the cursor on the current display terminal */
    if(term_num == get_cur_terminal()){
        set_cursor(terminal_arr[term_num-1].screen_x, terminal_arr[term_num-1].screen_y, 1);
        set_cursor_helper(terminal_arr[term_num-1].screen_x, terminal_arr[term_num-1].screen_y);
    }else{
        set_cursor(terminal_arr[term_num-1].screen_x, terminal_arr[term_num-1].screen_y, 0);
    }
}


/* int8_t* itoa(uint32_t value, int8_t* buf, int32_t radix);
 * Inputs: uint32_t value = number to convert
 *            int8_t* buf = allocated buffer to place string in
 *          int32_t radix = base system. hex, oct, dec, etc.
 * Return Value: number of bytes written
 * Function: Convert a number to its ASCII representation, with base "radix" */
int8_t* itoa(uint32_t value, int8_t* buf, int32_t radix) {
    static int8_t lookup[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    int8_t *newbuf = buf;
    int32_t i;
    uint32_t newval = value;

    /* Special case for zero */
    if (value == 0) {
        buf[0] = '0';
        buf[1] = '\0';
        return buf;
    }

    /* Go through the number one place value at a time, and add the
     * correct digit to "newbuf".  We actually add characters to the
     * ASCII string from lowest place value to highest, which is the
     * opposite of how the number should be printed.  We'll reverse the
     * characters later. */
    while (newval > 0) {
        i = newval % radix;
        *newbuf = lookup[i];
        newbuf++;
        newval /= radix;
    }

    /* Add a terminating NULL */
    *newbuf = '\0';

    /* Reverse the string and return */
    return strrev(buf);
}

/* int8_t* strrev(int8_t* s);
 * Inputs: int8_t* s = string to reverse
 * Return Value: reversed string
 * Function: reverses a string s */
int8_t* strrev(int8_t* s) {
    register int8_t tmp;
    register int32_t beg = 0;
    register int32_t end = strlen(s) - 1;

    while (beg < end) {
        tmp = s[end];
        s[end] = s[beg];
        s[beg] = tmp;
        beg++;
        end--;
    }
    return s;
}

/* uint32_t strlen(const int8_t* s);
 * Inputs: const int8_t* s = string to take length of
 * Return Value: length of string s
 * Function: return length of string s */
uint32_t strlen(const int8_t* s) {
    register uint32_t len = 0;
    while (s[len] != '\0')
        len++;
    return len;
}

/* void* memset(void* s, int32_t c, uint32_t n);
 * Inputs:    void* s = pointer to memory
 *          int32_t c = value to set memory to
 *         uint32_t n = number of bytes to set
 * Return Value: new string
 * Function: set n consecutive bytes of pointer s to value c */
void* memset(void* s, int32_t c, uint32_t n) {
    c &= 0xFF;
    asm volatile ("                 \n\
            .memset_top:            \n\
            testl   %%ecx, %%ecx    \n\
            jz      .memset_done    \n\
            testl   $0x3, %%edi     \n\
            jz      .memset_aligned \n\
            movb    %%al, (%%edi)   \n\
            addl    $1, %%edi       \n\
            subl    $1, %%ecx       \n\
            jmp     .memset_top     \n\
            .memset_aligned:        \n\
            movw    %%ds, %%dx      \n\
            movw    %%dx, %%es      \n\
            movl    %%ecx, %%edx    \n\
            shrl    $2, %%ecx       \n\
            andl    $0x3, %%edx     \n\
            cld                     \n\
            rep     stosl           \n\
            .memset_bottom:         \n\
            testl   %%edx, %%edx    \n\
            jz      .memset_done    \n\
            movb    %%al, (%%edi)   \n\
            addl    $1, %%edi       \n\
            subl    $1, %%edx       \n\
            jmp     .memset_bottom  \n\
            .memset_done:           \n\
            "
            :
            : "a"(c << 24 | c << 16 | c << 8 | c), "D"(s), "c"(n)
            : "edx", "memory", "cc"
    );
    return s;
}

/* void* memset_word(void* s, int32_t c, uint32_t n);
 * Description: Optimized memset_word
 * Inputs:    void* s = pointer to memory
 *          int32_t c = value to set memory to
 *         uint32_t n = number of bytes to set
 * Return Value: new string
 * Function: set lower 16 bits of n consecutive memory locations of pointer s to value c */
void* memset_word(void* s, int32_t c, uint32_t n) {
    asm volatile ("                 \n\
            movw    %%ds, %%dx      \n\
            movw    %%dx, %%es      \n\
            cld                     \n\
            rep     stosw           \n\
            "
            :
            : "a"(c), "D"(s), "c"(n)
            : "edx", "memory", "cc"
    );
    return s;
}

/* void* memset_dword(void* s, int32_t c, uint32_t n);
 * Inputs:    void* s = pointer to memory
 *          int32_t c = value to set memory to
 *         uint32_t n = number of bytes to set
 * Return Value: new string
 * Function: set n consecutive memory locations of pointer s to value c */
void* memset_dword(void* s, int32_t c, uint32_t n) {
    asm volatile ("                 \n\
            movw    %%ds, %%dx      \n\
            movw    %%dx, %%es      \n\
            cld                     \n\
            rep     stosl           \n\
            "
            :
            : "a"(c), "D"(s), "c"(n)
            : "edx", "memory", "cc"
    );
    return s;
}

/* void* memcpy(void* dest, const void* src, uint32_t n);
 * Inputs:      void* dest = destination of copy
 *         const void* src = source of copy
 *              uint32_t n = number of byets to copy
 * Return Value: pointer to dest
 * Function: copy n bytes of src to dest */
void* memcpy(void* dest, const void* src, uint32_t n) {
    asm volatile ("                 \n\
            .memcpy_top:            \n\
            testl   %%ecx, %%ecx    \n\
            jz      .memcpy_done    \n\
            testl   $0x3, %%edi     \n\
            jz      .memcpy_aligned \n\
            movb    (%%esi), %%al   \n\
            movb    %%al, (%%edi)   \n\
            addl    $1, %%edi       \n\
            addl    $1, %%esi       \n\
            subl    $1, %%ecx       \n\
            jmp     .memcpy_top     \n\
            .memcpy_aligned:        \n\
            movw    %%ds, %%dx      \n\
            movw    %%dx, %%es      \n\
            movl    %%ecx, %%edx    \n\
            shrl    $2, %%ecx       \n\
            andl    $0x3, %%edx     \n\
            cld                     \n\
            rep     movsl           \n\
            .memcpy_bottom:         \n\
            testl   %%edx, %%edx    \n\
            jz      .memcpy_done    \n\
            movb    (%%esi), %%al   \n\
            movb    %%al, (%%edi)   \n\
            addl    $1, %%edi       \n\
            addl    $1, %%esi       \n\
            subl    $1, %%edx       \n\
            jmp     .memcpy_bottom  \n\
            .memcpy_done:           \n\
            "
            :
            : "S"(src), "D"(dest), "c"(n)
            : "eax", "edx", "memory", "cc"
    );
    return dest;
}

/* void* memmove(void* dest, const void* src, uint32_t n);
 * Description: Optimized memmove (used for overlapping memory areas)
 * Inputs:      void* dest = destination of move
 *         const void* src = source of move
 *              uint32_t n = number of byets to move
 * Return Value: pointer to dest
 * Function: move n bytes of src to dest */
void* memmove(void* dest, const void* src, uint32_t n) {
    asm volatile ("                             \n\
            movw    %%ds, %%dx                  \n\
            movw    %%dx, %%es                  \n\
            cld                                 \n\
            cmp     %%edi, %%esi                \n\
            jae     .memmove_go                 \n\
            leal    -1(%%esi, %%ecx), %%esi     \n\
            leal    -1(%%edi, %%ecx), %%edi     \n\
            std                                 \n\
            .memmove_go:                        \n\
            rep     movsb                       \n\
            "
            :
            : "D"(dest), "S"(src), "c"(n)
            : "edx", "memory", "cc"
    );
    return dest;
}

/* int32_t strncmp(const int8_t* s1, const int8_t* s2, uint32_t n)
 * Inputs: const int8_t* s1 = first string to compare
 *         const int8_t* s2 = second string to compare
 *               uint32_t n = number of bytes to compare
 * Return Value: A zero value indicates that the characters compared
 *               in both strings form the same string.
 *               A value greater than zero indicates that the first
 *               character that does not match has a greater value
 *               in str1 than in str2; And a value less than zero
 *               indicates the opposite.
 * Function: compares string 1 and string 2 for equality */
int32_t strncmp(const int8_t* s1, const int8_t* s2, uint32_t n) {
    int32_t i;
    for (i = 0; i < n; i++) {
        if ((s1[i] != s2[i]) || (s1[i] == '\0') /* || s2[i] == '\0' */) {

            /* The s2[i] == '\0' is unnecessary because of the short-circuit
             * semantics of 'if' expressions in C.  If the first expression
             * (s1[i] != s2[i]) evaluates to false, that is, if s1[i] ==
             * s2[i], then we only need to test either s1[i] or s2[i] for
             * '\0', since we know they are equal. */
            return s1[i] - s2[i];
        }
    }
    return 0;
}

/* int8_t* strcpy(int8_t* dest, const int8_t* src)
 * Inputs:      int8_t* dest = destination string of copy
 *         const int8_t* src = source string of copy
 * Return Value: pointer to dest
 * Function: copy the source string into the destination string */
int8_t* strcpy(int8_t* dest, const int8_t* src) {
    int32_t i = 0;
    while (src[i] != '\0') {
        dest[i] = src[i];
        i++;
    }
    dest[i] = '\0';
    return dest;
}

/* int8_t* strcpy(int8_t* dest, const int8_t* src, uint32_t n)
 * Inputs:      int8_t* dest = destination string of copy
 *         const int8_t* src = source string of copy
 *                uint32_t n = number of bytes to copy
 * Return Value: pointer to dest
 * Function: copy n bytes of the source string into the destination string */
int8_t* strncpy(int8_t* dest, const int8_t* src, uint32_t n) {
    int32_t i = 0;
    while (src[i] != '\0' && i < n) {
        dest[i] = src[i];
        i++;
    }
    while (i < n) {
        dest[i] = '\0';
        i++;
    }
    return dest;
}

/* void test_interrupts(void)
 * Inputs: void
 * Return Value: void
 * Function: increments video memory. To be used to test rtc */
void test_interrupts(void) {
    int32_t i;
    for (i = 0; i < NUM_ROWS * NUM_COLS; i++) {
        video_mem[i << 1]++;
    }
}

/*
void rtc_open_write_test(){
	int i;

    for (i = 0; i < 120; i++){
        if (i == 80)
            putc('\n');
        else
            putc('1');
    }
}
*/

/* get_video_mem
 *  DESCRIPTION: gets video_mem value
 *  INPUT: none
 *  OUTPUT: none
 *  RETURN VALUE: video_mem
 *  SIDE EFFECT: none
 */
char* get_video_mem(){
    return video_mem;
}

/* set_video_mem
 *  DESCRIPTION: sets value of video_mem pointer
 *  INPUT:  val - val to set video_mem
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIDE EFFECT: changes video_mem pointer
 */
void set_video_mem(char* val){
    video_mem = val;
}

/* get_cur_terminal
 *  DESCRIPTION: gets the current terminal (1,2,3) on display
 *  INPUT: none
 *  OUTPUT: none
 *  RETURN VALUE: current terminal on display
 *  SIDE EFFECT: none
 */
int32_t get_cur_terminal(){
    return cur_terminal;
}

/* set_cur_terminal 
 *  DESCRIPTION: sets the current terminal on display
 *  INPUT: terminal - terminal to make active on display
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIDE EFFECT: changes display terminal value
 */
void set_cur_terminal(int32_t terminal){
    cur_terminal = terminal;
}

/* get_cur_terminal_running
 *  DESCRIPTION: returns the terminal (1,2,3) being handled by scheduler
 *  INPUT: none
 *  OUTPUT: none
 *  RETURN VALUE: terminal number being used by scheduler
 *  SIDE EFFECT: none
 */
int32_t get_cur_terminal_running(){

    return cur_terminal_running;
}

/* set_cur_terminal_running
 *  DESCRIPTION: sets the terminal being used by scheduler
 *  INPUT: terminal - terminal number to change to
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIDE EFFECT: changes value of terminal used by scheduler
 */
void set_cur_terminal_running(int32_t terminal){

    cur_terminal_running = terminal;
}


