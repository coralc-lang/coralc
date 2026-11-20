# ========================================================
# Module: gvndemo
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @f
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl f
f:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
.Lf_BB2:
    movz x9, #1
    movz x10, #2
    add x9, x9, x10
    str x9, [sp, #136]
    movz x9, #2
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #144]
    ldr x9, [sp, #136]
    ldr x10, [sp, #144]
    add x9, x9, x10
    str x9, [sp, #152]
    ldr x0, [sp, #152]
    b .Lf_epilogue
.Lf_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret


