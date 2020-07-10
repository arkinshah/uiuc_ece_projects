#  mp3-cp1.s version 3.0
.align 4
.section .text
.globl _start
_start:
    lw x1, DEAD
    lw x2, BEAD
    lw x4, FADE
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    slli x1, x1, 8
    nop
    nop
    nop
    slli x2, x2, 8
    nop
    nop
    nop
    slli x4, x4, 8
    nop
    nop
    nop
    THEEND:
    beq x0, x0, THEEND

.section .rodata
.balign 256
DEAD:   .word 0xDEADDEAD
BEAD:   .word 0xBEADBEAD    
FADE:   .word 0xFADEFADE
