#ifndef _KEYBOARD_H
#define _KEYBOARD_H

#include "lib.h"
#include "types.h"
#include "i8259.h"
#include "terminal.h"
#include "scheduling.h"
#include "system_call.h"

/* will change constants */
#define KEYBOARD_IRQ 1
#define KEYBOARD_DATA   0x60 	// sends scan codes in
#define KEYBOARD_STATUS 0x64 	// if keyboard is read

#define KEYBOARD_MAX_SZ	128

uint8_t keyboard_buffer[KEYBOARD_MAX_SZ];

/* flag to wait for enter press */
//int enter_pressed;

/* keeps track of current index */
//int current_index;

/* Initializes keyboard*/
extern void keyboard_init();

/* handles ctrl + l combo */
extern void ctrl_l();

/* halts current process */
extern void ctrl_c();

/* handles backspace */
extern void backspace();

/* adds TAB_SIZE spaces to buffer */
extern void tab();

/* handles enter presses */
extern void enter();

/* handles space presses */
extern void space();

/* Handles keyboard interrupt */
extern void keyboard_interrupt();

extern void alt_fn(int32_t num);

extern void set_terminals(int32_t index, int32_t value);

extern int32_t get_terminals(int32_t index);

#endif



