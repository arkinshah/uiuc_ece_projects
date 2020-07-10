#ifndef _SCHEDULING_H
#define _SCHEDULING_H

#include "types.h"
#include "lib.h"
#include "paging.h"
#include "x86_desc.h"
#include "terminal.h"
#include "pcb.h"
#include "system_call.h"

#define PAGE_INDEX_SHIFT 12
#define _8KB 0x2000
// #define NUM_COLS    80
// #define NUM_ROWS    25*2
#define INT_SIZE 4 /* Size of int in bytes*/

/* Make a new terminal active */
extern void make_terminal_active(int32_t terminal);
extern int32_t get_next_active_pid();
void switch_task_helper();


#endif
