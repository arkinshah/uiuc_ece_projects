#ifndef _TERMINAL_H
#define _TERMINAL_H

#include "types.h"
#include "lib.h"



/* does nothing */
extern int32_t terminal_open(const uint8_t *filename);

/* does nothing */
extern int32_t terminal_close(int32_t fd);

/* reads form keyboard buffer into terminal buffer */
extern int32_t terminal_read(int32_t fd, void *buf, int32_t nbytes);

/* writes to screen from terminal buffer */
extern int32_t terminal_write(int32_t fd, const void *buf, int32_t nbytes);

/* error function for stdin (write) */
extern int32_t error_function_stdin_write(int32_t fd, const void *buf, int32_t nbytes);

/* error function for stdout (read) */
extern int32_t error_function_stdout_read(int32_t fd, void *buf, int32_t nbytes);

void clear_screen_and_buffer(int32_t screen_x, int32_t screen_y);

#endif
