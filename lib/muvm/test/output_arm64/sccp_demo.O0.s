# ========================================================
# Module: sccpdemo
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @f
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 176 bytes
# ========================================================
    .text
.globl f
f:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #176
.Lf_BB2:
    movz x9, #1
    movz x10, #2
    add x9, x9, x10
    str x9, [sp, #136]
    ldr x9, [sp, #136]
    movz x10, #10
    cmp x9, x10
    cset w9, gt
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    cbz x9, .Lf_cse_10
    b .Lf_BB3
.Lf_cse_10:
    b .Lf_BB4
.Lf_BB3:
    ldr x9, [sp, #136]
    movz x10, #100
    add x9, x9, x10
    str x9, [sp, #152]
    ldr x0, [sp, #152]
    b .Lf_epilogue
.Lf_BB4:
    movz x0, #7
    b .Lf_epilogue
.Lf_epilogue:
    add sp, sp, #176
    ldp x29, x30, [sp], #16
    ret


