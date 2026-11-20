# ========================================================
# Module: gvndemo
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @f
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 144 bytes
# ========================================================
    .text
.globl f
f:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #144
.Lf_BB2:
    movz x0, #6
    b .Lf_epilogue
.Lf_epilogue:
    add sp, sp, #144
    ldp x29, x30, [sp], #16
    ret


