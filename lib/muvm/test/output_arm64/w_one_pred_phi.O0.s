# ========================================================
# Module: onepredphi
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
    mov w9, w0
    str x9, [sp, #136]
.Lf_BB3:
    b .Lf_BB4
.Lf_BB4:
    ldr x9, [sp, #136]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    str x9, [sp, #152]
    b .Lf_BB5
.Lf_BB5:
    ldr x9, [sp, #152]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #160]
    ldr x0, [sp, #160]
    b .Lf_epilogue
.Lf_epilogue:
    add sp, sp, #176
    ldp x29, x30, [sp], #16
    ret


