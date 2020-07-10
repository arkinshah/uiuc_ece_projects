.align 5
.section .text
.globl _start

_start:
	lw x6, DEEB
    la x16, ZOOP

    sb x6, 0(x16)
    lw x4, ZOOP
    sb x6, 1(x16)
    lw x4, ZOOP
    sb x6, 2(x16)
    lw x4, ZOOP
    sb x6, 3(x16)
    lw x4, ZOOP

halt:
    beq x0, x0, halt

.section .rodata
.balign 256

ZOOP :  .word 0x0000700F
DEEB:   .word 0xDEEBDEEB
