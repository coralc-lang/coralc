# ========================================================
# Module: const_fold
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 176 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #176
.Lmain_BB2:
    movz x9, #2
    movz x10, #3
    add x9, x9, x10
    str x9, [sp, #136]
    ldr x9, [sp, #136]
    movz x10, #4
    mul x9, x9, x10
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    movz x10, #6
    sub x9, x9, x10
    str x9, [sp, #152]
    ldr x9, [sp, #152]
    movz x10, #2
    sdiv x9, x9, x10
    str x9, [sp, #160]
    ldr x9, [sp, #160]
    str x9, [sp, #168]
    ldr x0, [sp, #168]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #176
    ldp x29, x30, [sp], #16
    ret


