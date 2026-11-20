# ========================================================
# Module: folddemo
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
    mov w9, w0
    str x9, [sp, #136]
    mov w9, w1
    str x9, [sp, #144]
.Lf_BB4:
    movz x0, #5
    b .Lf_epilogue
.Lf_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret


