#ifndef ASM

#include "exception_handlers.h"
#include "system_call.h"
#include "scheduling.h"
#include "paging.h"
#include "x86_desc.h"

#define ESP 264
#define EBP (ESP+4)
#define EIP (ESP+8)

/* exception handlers */

extern void divide_by_zero_linkage();
extern void single_step_interrupt_linkage();
extern void NMI_linkage();
extern void break_point_linkage();
extern void overflow_linkage();
extern void bounds_linkage();
extern void invalid_op_code_linkage();
extern void coprocessor_not_availiable_linkage();
extern void double_fault_linkage();
extern void coprocessor_segment_overrun_linkage();
extern void invalid_task_state_segment_linkage();
extern void segment_not_present_linkage();
extern void stack_fault_linkage();
extern void general_protection_fault_linkage();
extern void page_fault_linkage();
extern void math_fault_linkage();
extern void alignment_check_linkage();
extern void machine_check_linkage();
extern void SIMD_floating_point_exception_linkage();
extern void virtualization_exception_linkage();
extern void control_protection_exception_linkage();
extern void general_exception_linkage();


/* interrupt handlers */

/* handles rtc interrupts */
extern void rtc_linkage();

/* handles keyboard interrupts */
extern void keyboard_linkage();

/* handles system call interrupts */
extern void system_call_linkage();

/* handles pit interrupts */
extern void pit_linkage();

#endif

