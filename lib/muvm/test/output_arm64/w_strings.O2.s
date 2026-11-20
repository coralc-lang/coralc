# ========================================================
# Module: strings
# Target: AArch64 / AAPCS64
# ========================================================

# ---- String Constants ----
    .section .rodata
    .align 1
msg:
    .asciz "abc"

# ---- Global Variables ----
    .data
    .align 8
.globl first
first:
    .quad 0

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 256 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #256
.Lmain_BB5:
    adrp x9, msg
    add x9, x9, :lo12:msg
    str x9, [sp, #136]
    adrp x9, msg
    add x9, x9, :lo12:msg
    add x9, x9, #1
    str x9, [sp, #144]
    ldr x9, [sp, #136]
    adrp x10, first
    add x10, x10, :lo12:first
    str x9, [x10]
    ldr x9, [sp, #136]
    ldrb w10, [x9]
    str x10, [sp, #152]
    ldr x9, [sp, #144]
    ldrb w10, [x9]
    str x10, [sp, #160]
    adrp x9, first
    add x9, x9, :lo12:first
    ldr x10, [x9]
    str x10, [sp, #168]
    ldr x9, [sp, #168]
    str x9, [sp, #176]
    ldr x9, [sp, #176]
    add x9, x9, #2
    str x9, [sp, #184]
    ldr x9, [sp, #184]
    ldrb w10, [x9]
    str x10, [sp, #192]
    ldr x9, [sp, #152]
    and x9, x9, #255
    str x9, [sp, #200]
    ldr x9, [sp, #160]
    and x9, x9, #255
    str x9, [sp, #208]
    ldr x9, [sp, #192]
    and x9, x9, #255
    str x9, [sp, #216]
    ldr x9, [sp, #200]
    ldr x10, [sp, #208]
    eor x9, x9, x10
    str x9, [sp, #224]
    ldr x9, [sp, #224]
    ldr x10, [sp, #216]
    eor x9, x9, x10
    str x9, [sp, #232]
    ldr x9, [sp, #232]
    str x9, [sp, #240]
    ldr x0, [sp, #240]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #256
    ldp x29, x30, [sp], #16
    ret


