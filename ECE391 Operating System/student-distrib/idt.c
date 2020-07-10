/* build IDT and fill with interrupt handlers */
#include "idt.h"
#include "rtc.h"
#include "keyboard.h"
#include "assembly_linkage.h"
#include "pit.h"
//#include "lib.c"

#define USER_PRIVILEGE 3
#define KERNEL_PRIVILEGE 0

/* init_idt
 *  DESCRIPTION: initalizes the idt by filling the IDT with exception and interrupt handlers
 *  INPUT: none
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIDE EFFECT: fills the IDT
 */
void init_idt(){
    int i;
    
    /* Hardware interrupt handlers and exception handlers have DPL = 0
     * Systemcall Handler should have DPL = 3, and accessible from USER SPACE.
     * 
     *  reserved bits:  4|3|2|1|0
     * 
     * Interrupt Gate:  0|0|1|1|0
     *      *used for interrupts
     *          *interrupts automatically disabled upon entry and reenabled upon IRET which restores EFLAGS
     * 
     * Trap Gate     :  0|1|1|1|0
     *      *used for exceptions
     *          *Does not disable interrupts upon entry
     * 
     * Descriptor Priviledge Level
     *  DPL = 0 --> Kernel Privilege
     *  DPL = 3 --> User Privilege 
     * 
     */
	 
    
    /* fills IDT with reserved exceptions [0x00, 0x15] */
    for (i = 0; i < INTEL_RESERVED; i++){
        idt[i].seg_selector = KERNEL_CS;
        idt[i].present = 1;
        idt[i].dpl = KERNEL_PRIVILEGE;
        idt[i].size = 1;
        idt[i].reserved4 = 0;
        idt[i].reserved3 = 1;           /* using trap gate (32-bit) */
        idt[i].reserved2 = 1;
        idt[i].reserved1 = 1;
        idt[i].reserved0 = 0;
    }

    /* Sets the IDT vectors [0x00, 0x15] with handler linkages */
    SET_IDT_ENTRY(idt[0x00], divide_by_zero_linkage);
    SET_IDT_ENTRY(idt[0x01], single_step_interrupt_linkage);
    SET_IDT_ENTRY(idt[0x02], NMI_linkage);
    SET_IDT_ENTRY(idt[0x03], break_point_linkage);
    SET_IDT_ENTRY(idt[0x04], overflow_linkage);
    SET_IDT_ENTRY(idt[0x05], bounds_linkage);
    SET_IDT_ENTRY(idt[0x06], invalid_op_code_linkage);
    SET_IDT_ENTRY(idt[0x07], coprocessor_not_availiable_linkage);
    SET_IDT_ENTRY(idt[0x08], double_fault_linkage);
    SET_IDT_ENTRY(idt[0x09], coprocessor_segment_overrun_linkage);
    SET_IDT_ENTRY(idt[0x0A], invalid_task_state_segment_linkage);
    SET_IDT_ENTRY(idt[0x0B], segment_not_present_linkage);
    SET_IDT_ENTRY(idt[0x0C], stack_fault_linkage);
    SET_IDT_ENTRY(idt[0x0D], general_protection_fault_linkage);
    SET_IDT_ENTRY(idt[0x0E], page_fault_linkage);
    /* 0x0F is marked as "reserved" by intel */
    SET_IDT_ENTRY(idt[0x10], math_fault_linkage);
    SET_IDT_ENTRY(idt[0x11], alignment_check_linkage);
    SET_IDT_ENTRY(idt[0x12], machine_check_linkage);
    SET_IDT_ENTRY(idt[0x13], SIMD_floating_point_exception_linkage);
    SET_IDT_ENTRY(idt[0x14], virtualization_exception_linkage);
    SET_IDT_ENTRY(idt[0x15], control_protection_exception_linkage);


    /* Set the rest all of Reserved vectors (0x20 - 0xFF) to a general exception */
    for (i = INTEL_RESERVED; i < MAX_INTERRUPT_VECTORS; i++){
        idt[i].seg_selector = KERNEL_CS;
        idt[i].present = 1;
        idt[i].dpl = KERNEL_PRIVILEGE;
        idt[i].size = 1;
        idt[i].reserved4 = 0;
        idt[i].reserved3 = 0;               /* using interrupt gate (32-bit) */
        idt[i].reserved2 = 1;
        idt[i].reserved1 = 1;
        idt[i].reserved0 = 0;
        /* load the entry into IDT */
        SET_IDT_ENTRY(idt[i], general_exception_linkage);
    }

    /**** Manually set values for device interrupt entries ****/
    /******* interrupt gates are used for these entries *******/

    /* create entry for Keyboard Interrupts */
    SET_IDT_ENTRY(idt[KEYBOARD_VECTOR], keyboard_linkage);

    /* create entry for RTC interrupts */
    SET_IDT_ENTRY(idt[RTC_VECTOR], rtc_linkage);

    /* create entry for PIT interrupts */
    SET_IDT_ENTRY(idt[PIT_VECTOR], pit_linkage);

    /* create entry for System call interrupts */
    idt[SYSTEM_CALL_VECTOR].dpl = USER_PRIVILEGE;           /* User priviledge */
    idt[SYSTEM_CALL_VECTOR].reserved3 = 1;     /* using trap gate (32-bit) */
    SET_IDT_ENTRY(idt[SYSTEM_CALL_VECTOR], system_call_linkage);

    /* load IDT into IDTR */
    lidt(idt_desc_ptr);

}
