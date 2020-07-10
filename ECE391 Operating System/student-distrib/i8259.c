/* i8259.c - Functions to interact with the 8259 interrupt controller
 * vim:ts=4 noexpandtab
 */

#include "i8259.h"
#include "lib.h"

/* https://wiki.osdev.org/8259_PIC#Handling_Spurious_IRQs */

/* Interrupt masks to determine which interrupts are enabled and disabled */
uint8_t master_mask = IR2_MASK; /* IRQs 0-7  */
uint8_t slave_mask = PIC_MASK;  /* IRQs 8-15 */

/* Initialize the 8259 PIC */
void i8259_init(void) {
   
    /* init Master PIC */
    outb(ICW1, MASTER_8259_PORT);
    outb(ICW2_MASTER, MASTER_DATA_PORT);
    outb(ICW3_MASTER, MASTER_DATA_PORT);
    outb(ICW4, MASTER_DATA_PORT);

    /* init Slave PIC */
    outb(ICW1, SLAVE_8259_PORT);
    outb(ICW2_SLAVE, SLAVE_DATA_PORT);
    outb(ICW3_SLAVE, SLAVE_DATA_PORT);
    outb(ICW4, SLAVE_DATA_PORT);

    outb(master_mask, MASTER_DATA_PORT);
    outb(slave_mask, SLAVE_DATA_PORT);

    /* Enable irq on master */
    enable_irq(2);
    
}

/* Enable (unmask) the specified IRQ 
 *
 * Master IRQ#  0-7
 * Slave  IRQ#  8-15
 * 
 * https://wiki.osdev.org/8259_PIC#Handling_Spurious_IRQs
 */
void enable_irq(uint32_t irq_num) {
    /* irq_num (low 3 bits) use to identify which IR is being reported*/
    uint16_t port;
    uint8_t value;
    uint8_t left_shift;

    if(irq_num < 0 || irq_num > 15){ //invalid irq_num
        return;
    }

    if(irq_num < 8){port = MASTER_DATA_PORT; left_shift = irq_num;}
    else {port = SLAVE_DATA_PORT; left_shift = irq_num - 8;}

    //get current value
    value = inb(port);
    left_shift = ~(1 << left_shift);
    value = value & left_shift;

    outb(value, port);
}

/* Disable (mask) the specified IRQ
 *
 * Master IRQ#  0-7
 * Slave  IRQ#  8-15
 * 
 */
void disable_irq(uint32_t irq_num) {
    uint16_t port;
    uint8_t value;
    uint8_t left_shift;

    if(irq_num < 0 || irq_num > 15){ //invalid irq_num
        return;
    }

    if(irq_num < 8){port = MASTER_DATA_PORT; left_shift = irq_num;}
    else {port = SLAVE_DATA_PORT; left_shift = irq_num - 8;}

    //get current value
    value = inb(port);
    left_shift = (1 << left_shift);
    value = value | left_shift;

    outb(value, port);
}

/* Send end-of-interrupt signal for the specified IRQ */
void send_eoi(uint32_t irq_num) {
    uint16_t port;
    uint8_t value;
    // uint8_t left_shift;

    if(irq_num < 0 || irq_num > 15){ //invalid irq_num
        return;
    }

    if(irq_num > 7){ //send to slave and master both
        value = irq_num - 8;
        value = EOI | value;
        port  = SLAVE_8259_PORT;
        outb(value, port);
         
         //send EOI to master port now (IRQ_2)
        value = EOI | 2; //IRQ_2 port
        port = MASTER_8259_PORT;
        outb(value, port);
        return;
    }

    //IRQ <= 7, therefore only have to use Master
    value = EOI | irq_num;
    port = MASTER_8259_PORT;
    outb(value ,port);
}
