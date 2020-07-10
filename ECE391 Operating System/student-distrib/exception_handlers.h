#ifndef _EXCEPTION_HANDLERS
#define _EXCEPTION_HANDLERS

#include "lib.h"
#include "system_call.h"


/* exceptions used in the IDT and defined by INTEL */
/* https://en.wikipedia.org/wiki/Interrupt_descriptor_table */

/**** TEMP****/
extern void system_call_handler();

/* handles divide by zero exception */
extern void divide_by_zero();

/* handles single step interrupt exception */
extern void single_step_interrupt();

/* handles non-maskable interrupt */
extern void NMI();

/* handles break point exception */
extern void break_point();

/* handles overflow exception */
extern void overflow();

/* handles bounds exception */
extern void bounds();

/* handles invalid op code exception */
extern void invalid_op_code();

/* handles Coprocessor Segment Overrun exception */
extern void coprocessor_not_availiable();

/* handles Coprocessor Segment Overrun exception */
extern void double_fault();

/* handles Coprocessor Segment Overrun exception */
extern void coprocessor_segment_overrun();

/* handles 	Invalid Task State Segment exception */
extern void invalid_task_state_segment();

/* handles 	Segment not present exception */
extern void segment_not_present();

/* handles Stack Fault exception */
extern void stack_fault();

/* handles General protection fault exception */
extern void general_protection_fault();

/* handles Page fault exception */
extern void page_fault();

/* handles Math Fault exception */
extern void math_fault();

/* handles Alignment Check exception */
extern void alignment_check();

/* handles 	Machine Check exception */
extern void machine_check();

/* handles SIMD Floating-Point Exception exception */
extern void SIMD_floating_point_exception();

/* handles Virtualization Exception exception */
extern void virtualization_exception();

/* handles Control Protection Exceptionn exception */
extern void control_protection_exception();

/* handles General Exceptions */
extern void general_exception();


#endif
