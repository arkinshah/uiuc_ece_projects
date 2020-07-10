#ifndef _IDT_H
#define _IDT_H

#include "x86_desc.h"
#include "lib.h"
#include "i8259.h"
#include "exception_handlers.h"
#include "types.h"
#include "assembly_linkage.h"

/* IDT consist of 256 interrupt vectors, first 20 are reserved for exceptions */
#define MAX_INTERRUPT_VECTORS 256 
#define INTEL_RESERVED       0x20      // first 20 [0x00, 0x15] are INTEL exceptions

/* interrupt vectors for devices and system calls */
#define SYSTEM_CALL_VECTOR    0x80
#define RTC_VECTOR            0x28
#define KEYBOARD_VECTOR       0x21
#define PIT_VECTOR            0x20

/* initalizes the idt */
extern void init_idt();



#endif
