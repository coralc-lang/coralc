# ========================================================
# Module: ptr_eq
# Target: AArch64 / AAPCS64
# ========================================================

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
.Lmain_BB2:
    add x9, sp, #136
    str x9, [sp, #128]
    add x9, sp, #152
    str x9, [sp, #144]
    movz x9, #1
    ldr x10, [sp, #128]
    str w9, [x10]
    movz x9, #2
    ldr x10, [sp, #144]
    str w9, [x10]
    ldr x9, [sp, #128]
    ldr x10, [sp, #144]
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #168]
    ldr x9, [sp, #168]
    and x9, x9, #255
    str x9, [sp, #176]
    ldr x0, [sp, #176]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #192
    ldp x29, x30, [sp], #16
    ret


