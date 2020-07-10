#include "exception_handlers.h"

/* for any exception
 *  DESCRIPTION: handle a raised exception by printing what exception was raised and returns command back to the shell
 *               and passes 256 into halt
 *  INPUT: none
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIDE_EFFECT: print to screen the exception and take control away from user
 */


/* handles divide by zero exception */
void divide_by_zero(){
    cli();

    /* clear the screen just so we can see the message better */
    //clear();
    printf("Divide by zero!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles single step interrupt exception */
void single_step_interrupt(){
    cli();

    //clear();
    printf("Single step interrupt!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles non-maskable interrupt */
void NMI(){
    cli();

    //clear();
    printf("Non-maskable Interrupt\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles break point exception */
void break_point(){
    cli();

    //clear();
    printf("Break point exception!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles overflow exception */
void overflow(){
    cli();

    //clear();
    printf("Overflow exception!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles bounds exception */
void bounds(){
    cli();

    //clear();
    printf("Bounds exception!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles invalid op code exception */
void invalid_op_code(){
    cli();

    //clear();
    printf("Invalid Opcode!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles Coprocessor Segment Overrun exception */
void coprocessor_not_availiable(){
    cli();

    //clear();
    printf("Coprocessor Not Availiable!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles Coprocessor Segment Overrun exception */
void double_fault(){
    cli();

    //clear();
    printf("Double Fault!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles Coprocessor Segment Overrun exception */
void coprocessor_segment_overrun(){
    cli();

    //clear();
    printf("Coprocessor Segment Overrun!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles 	Invalid Task State Segment exception */
void invalid_task_state_segment(){
    cli();

    //clear();
    printf("Invalid Task State Segment!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles 	Segment not present exception */
void segment_not_present(){
    cli();

    //clear();
    printf("Segment Not Present!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles Stack Fault exception */
void stack_fault(){
    cli();

    //clear();
    printf("Stack Fault!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles General protection fault exception */
void general_protection_fault(){
    cli();

    //clear();
    printf("General Protection Fault!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles Page fault exception */
void page_fault(){
    cli();

    ////clear();
    printf("Page Fault!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles Math Fault exception */
void math_fault(){
    cli();

    //clear();
    printf("Math Fault!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles Alignment Check exception */
void alignment_check(){
    cli();

    //clear();
    printf("Aligment Check!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles 	Machine Check exception */
void machine_check(){
    cli();

    //clear();
    printf("Machine Check!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles SIMD Floating-Point Exception exception */
void SIMD_floating_point_exception(){
    cli();

    //clear();
    printf("SIMD Floating Point!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles Virtualization Exception exception */
void virtualization_exception(){
    cli();

    //clear();
    printf("Virtualization Exception!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles Control Protection Exceptionn exception */
void control_protection_exception(){
    cli();

    //clear();
    printf("Control Protection\n!");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}

/* handles General Exception */
void general_exception(){
    cli();

    //clear();
    printf("General Exception!\n");
    set_exception_raised(1);
    halt((uint8_t)256);

    sti();
}



