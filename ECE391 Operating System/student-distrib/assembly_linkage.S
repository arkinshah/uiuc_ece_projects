#define ASM 1

#include "assembly_linkage.h"

.data

    ESP_ = 264
    EBP_ = 268

.globl k_ESP
.globl k_EBP

k_ESP: .long 0
k_EBP: .long 0

.text
/* interrupts */
.global rtc_linkage, keyboard_linkage, system_call_linkage, pit_linkage

/*System Calls*/
/*.global halt, execute, read, write, open, close*/

/* exceptions */
.global divide_by_zero_linkage, single_step_interrupt_linkage, NMI_linkage, break_point_linkage, overflow_linkage, bounds_linkage
.global invalid_op_code_linkage, coprocessor_not_availiable_linkage, double_fault_linkage, coprocessor_segment_overrun_linkage
.global invalid_task_state_segment_linkage, segment_not_present_linkage, stack_fault_linkage, general_protection_fault_linkage
.global page_fault_linkage, math_fault_linkage, alignment_check_linkage, machine_check_linkage, SIMD_floating_point_exception_linkage
.global general_exception_linkage
.global virtualization_exception_linkage, control_protection_exception_linkage
; .global pf

; pf:
;     addl    $4, %esp
;     iret

/*****EXCEPTION LINKAGE******/

/* exception
 *  DESCRIPTION: all exceptions do the following: assembly linkage calls expcetion handler
 *  INPUT:  none
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIDE EFFECT: none
 */

divide_by_zero_linkage:
    pushal
    pushfl

    call divide_by_zero

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret

single_step_interrupt_linkage:
    pushal
    pushfl

    call single_step_interrupt

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret   

NMI_linkage:
    pushal
    pushfl

    call NMI

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret

break_point_linkage:
    pushal
    pushfl

    call break_point

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret

overflow_linkage:
    pushal
    pushfl

    call overflow

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret

bounds_linkage:
    pushal
    pushfl

    call bounds

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret

invalid_op_code_linkage:
    pushal
    pushfl

    call invalid_op_code

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret

coprocessor_not_availiable_linkage:
    pushal
    pushfl

    call coprocessor_not_availiable

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret

double_fault_linkage:
    pushal
    pushfl

    call double_fault

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret

coprocessor_segment_overrun_linkage:
    pushal
    pushfl

    call coprocessor_segment_overrun

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret

invalid_task_state_segment_linkage:
    pushal
    pushfl

    call invalid_task_state_segment

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret

segment_not_present_linkage:
    pushal
    pushfl

    call segment_not_present

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret

stack_fault_linkage:
    pushal
    pushfl

    call stack_fault

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret

general_protection_fault_linkage:
    pushal
    pushfl

    call general_protection_fault

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret

page_fault_linkage:
    pushal
    pushfl

    call page_fault

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret

math_fault_linkage:
    pushal
    pushfl

    call math_fault

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret

alignment_check_linkage:
    pushal
    pushfl

    call alignment_check

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret

machine_check_linkage:
    pushal
    pushfl

    call machine_check

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret
 
SIMD_floating_point_exception_linkage:
    pushal
    pushfl

    call SIMD_floating_point_exception

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret

virtualization_exception_linkage:
    pushal
    pushfl

    call virtualization_exception

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret
 
control_protection_exception_linkage:
    pushal
    pushfl

    call control_protection_exception

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret
 
general_exception_linkage:
    pushal
    pushfl

    call general_exception

    popfl
    popal

    /* some exceptions shouldn't even make it here */
    iret

    
/*****INTERRUPT LINKAGE******/

/* rtc_linkage
 *  DESCRIPTION: assembly linkage following C calling convention for rtc interrupts
 *  INPUT: none
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIZE EFFECT: calls rtc interrupt handler
 */
rtc_linkage:
    pushal
    pushfl

    call rtc_interrupt

    popfl
    popal

    iret

/* keyboard_linkage
 *  DESCRIPTION: assembly linkage following C calling convention for keyboard interrupts
 *  INPUT: none
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIZE EFFECT: calls keyboard interrupt handler
 */
keyboard_linkage:
    pushal
    pushfl

    /*pushl %eax

    leal k_return, %ebx
    pushl %ebx
    pushl %ebp
    movl %esp, k_EBP

    pushl %ebx
    pushl %esi
    pushl %edi
    movl %esp, k_ESP*/

    call keyboard_interrupt

    /*addl $24, %esp*/

    popfl
    popal
    
    iret

/* pit_linkage
 *  DESCRIPTION: assembly linkage following C calling convention for PIT
 *  INPUT: none
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIZE EFFECT: calls pit interrupt handler
pit_linkage:
    pushal
    pushfl

    call pit_interrupt

    popfl
    popal

    iret
*/

/* system_call_linkage
 *  DESCRIPTION: assembly linkage following C calling convention for system_call interrupts
 *  INPUT: none
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIDE EFFECT: calls system_call handler
 */
system_call_linkage:

    cmpl $1, %eax
    je set_cli
    cmpl $2, %eax
    je set_cli
    jmp push_registers
set_cli:
    cli
push_registers:
    pushw   %gs
    pushw   %fs
    pushw   %es
    pushw   %ds
    pushl   %ebp
    pushl   %edi
    pushl   %esi
    pushl   %edx
    pushl   %ecx
    pushl   %ebx

    cmpl    $1, %eax
    jl      invalid
    cmpl    $8, %eax
    jg      invalid

    call    *system_calls(, %eax, 4)
    jmp     success

invalid: 
    movl    $-1, %eax
success:
    popl    %ebx
    popl    %ecx
    popl    %edx
    popl    %esi
    popl    %edi
    popl    %ebp
    popw    %ds
    popw    %es
    popw    %fs
    popw    %gs
    iret

system_calls:
    .long   0, halt, execute, read, write, open, close, getargs, vidmap


pit_linkage:
    pushal
    pushfl

    call switch_tasks

    popfl
    popal
    iret



