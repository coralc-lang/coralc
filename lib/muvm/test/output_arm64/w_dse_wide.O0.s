# ========================================================
# Module: parsed
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
    add x9, sp, #136
    str x9, [sp, #128]
    mov x9, xzr
    ldr x10, [sp, #128]
    str x9, [x10]
    movz x9, #0
    movk x9, #170, lsl #32
    ldr x10, [sp, #128]
    str x9, [x10]
    movz x9, #5
    ldr x10, [sp, #128]
    str w9, [x10]
    ldr x9, [sp, #128]
    ldr x10, [x9]
    str x10, [sp, #152]
    ldr x9, [sp, #152]
    movz x10, #32
    lsr x9, x9, x10
    str x9, [sp, #160]
    ldr x9, [sp, #160]
    str x9, [sp, #168]
    ldr x0, [sp, #168]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #176
    ldp x29, x30, [sp], #16
    ret


