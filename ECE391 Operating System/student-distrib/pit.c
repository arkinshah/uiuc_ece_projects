#include "pit.h"

/* pit_init
 *  DESCRIPTION: initalize pit
 *  INPUT: none
 *  OUTPUT: none
 *  RETURN VALUE: noen
 *  SIDE EFFECT: pit intialized
 */
void pit_init(){

    /* Start critical section to write to PIT */
    cli();

    outb(COMMAND, REGISTER_PORT);

    int32_t reload_value =  RELOAD_VALUE/FREQUENCY;
    uint8_t bottom_eight = reload_value & 0xFF;
    outb(bottom_eight, CHANNEL_0);

    uint8_t top_eight = (reload_value >> BYTE) & 0xFF;
    outb(top_eight, CHANNEL_0);

    /* End of Critical Section */
    sti();

    /* Enable the IRQ for PIC on the 8259 PIC (unmask it) */
    enable_irq(PIT_IRQ);
}

/* pit_interrupt
 *  DESCRIPTION: sends IRQ for pit
 *  INTPUT: none
 *  OUTPUT: none
 *  RETURN VALUE: none
 *  SIDE EFFECT: tells pic we're done with PIT
 */
void pit_interrupt(){
    /* Send End of Interrupt to indicate interrupt handled */
	send_eoi(PIT_IRQ);
}



