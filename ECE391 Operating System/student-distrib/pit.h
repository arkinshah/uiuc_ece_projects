#ifndef _PIT_H
#define _PIT_H

#include "types.h"
#include "i8259.h"
#include "lib.h"

#define CHANNEL_0       0x40          /* Data Port for Rate Generator Mode */
#define REGISTER_PORT   0X43          /* Command/Mode Register */
#define PIT_IRQ         0
#define COMMAND         0x34          /* Channel 0, lobyte/hibyte, rate generator, BCD = False */
#define FREQUENCY       50
#define RELOAD_VALUE    (3579545 / 3)
#define BYTE            8

/* Initialize PIT */
extern void pit_init();

/* PIT Interrupt Handler */
extern void pit_interrupt();

#endif



