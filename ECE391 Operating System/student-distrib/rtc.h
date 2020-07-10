#ifndef _RTC_H
#define _RTC_H

#include "i8259.h"
#include "lib.h"
#include "types.h"

#define RTC_IRQ 8 /* As described in the OS dev documentation for the RTC */
#define REG_NUM 0x70 /* Specifies register number to write to and enables/disables NMI */
#define REG_DATA 0x71 /* Data to write to the chosen register */
#define MASK_8 0x80 /* Mask the 8th lowest bit */
#define UNMASK_8 0x7F /* Unmask the 8th lowest bit */
#define REG_A 0x0A /* Register A offset in the RTC */
#define REG_B 0x0B /* Register B offset in the RTC */
#define REG_C 0x0C /* Register C offset in the RTC */
#define MASK_7 0x40 /* Mask the 7th lowest bit */
#define RTC_BASE_FREQ 32768 /* Default RTC base frequency */
#define RTC_FIRST_USABLE_FREQ (RTC_BASE_FREQ >> 2)	/* The first usable rtc frequency */
#define HIGHEST_ALLOWED_FREQ 1024 /* Highest frequency permitted by the kernal for any interrupt*/
#define LOWEST_ALLOWED_FREQ 2 /* Lowest frequency accepted by RTC */
#define MASK_4_BITS_0 0x0F /* Mask bits 3-0 */
#define MASK_4_BITS_1 0xF0 /* Mask bits 7-4 */
#define TWO_HZ_FIFTEEN 15 /* 2hZ = 15 */
#define RTCDOUBLE	2     /* 2hZ */
#define RTC15		15
#define RTCCOUNT	80
#define RTC4        4     /* 4hZ */
#define RTC16       16    /* 16hZ */ 
#define RTC32       32    /* 32hZ */
#define RTC64       64    /* 64hZ */
#define RTC128      128   /* 128hZ */
#define RTC256      256   /* 256hZ */
#define RTC512      512   /* 512hZ */
#define RTC1024     1024  /* 1024hZ */
#define RTC6		6     /* 6 -> rate_val */
#define RTC7        7     /* 7 -> rate_val */
#define RTC8        8     /* 8 -> rate_val and 8hz*/
#define RTC9        9     /* 9 -> rate_val */
#define RTC10       10    /* 10 -> rate_val */
#define RTC11       11    /* 11 -> rate_val */
#define RTC12       12    /* 12 -> rate_val */
#define RTC13       13    /* 13 -> rate_val */
#define RTC14       14    /* 14 -> rate_val */
#define RTC15       15    /* 15 -> rate_val */
#define FREQ_SCALE  3     /* scales frequency for virtualization */

/* Initialize RTC */
extern void rtc_init();

/* RTC interrupt handler */
extern void rtc_interrupt();

/* Reads from RTC */
extern int32_t rtc_read(int32_t fd, void* buf, int32_t nbytes);

/* Writes the frequency of RTC periodic interrupts */
extern int32_t rtc_write(int32_t fd, const void* buf, int32_t nbytes);

/*Opens RTC*/
extern int32_t rtc_open(const uint8_t* filename);

/*Closes RTC*/
extern int32_t rtc_close(int32_t fd);

#endif
