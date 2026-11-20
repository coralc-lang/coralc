# ========================================================
# Module: globals
# Target: AArch64 / AAPCS64
# ========================================================

# ---- Global Variables ----
    .data
    .align 8
.globl counter
counter:
    .quad 10
    .section .rodata
    .align 8
.globl answer
answer:
    .quad 42
    .data
    .align 8
.globl alias
alias:
    .quad counter

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 192 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #192
.Lmain_BB7:
    adrp x9, counter
    add x9, x9, :lo12:counter
    ldr x10, [x9]
    str x10, [sp, #136]
    adrp x9, answer
    add x9, x9, :lo12:answer
    ldr x10, [x9]
    str x10, [sp, #144]
    ldr x9, [sp, #136]
    ldr x10, [sp, #144]
    add x9, x9, x10
    str x9, [sp, #152]
    ldr x9, [sp, #152]
    adrp x10, counter
    add x10, x10, :lo12:counter
    str x9, [x10]
    adrp x9, alias
    add x9, x9, :lo12:alias
    ldr x10, [x9]
    str x10, [sp, #160]
    ldr x9, [sp, #160]
    ldr x10, [x9]
    str x10, [sp, #168]
    ldr x9, [sp, #168]
    str x9, [sp, #176]
    ldr x0, [sp, #176]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #192
    ldp x29, x30, [sp], #16
    ret


