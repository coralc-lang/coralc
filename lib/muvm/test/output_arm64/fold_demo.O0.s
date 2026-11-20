# ========================================================
# Module: folddemo
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @f
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 208 bytes
# ========================================================
    .text
.globl f
f:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #208
    mov w9, w0
    str x9, [sp, #136]
    mov w9, w1
    str x9, [sp, #144]
.Lf_BB4:
    ldr x9, [sp, #136]
    mov x10, xzr
    add x9, x9, x10
    str x9, [sp, #152]
    ldr x9, [sp, #144]
    movz x10, #1
    mul x9, x9, x10
    str x9, [sp, #160]
    ldr x9, [sp, #152]
    mov x10, xzr
    mul x9, x9, x10
    str x9, [sp, #168]
    ldr x9, [sp, #160]
    ldr x10, [sp, #160]
    sub x9, x9, x10
    str x9, [sp, #176]
    ldr x9, [sp, #168]
    movz x10, #5
    add x9, x9, x10
    str x9, [sp, #184]
    ldr x9, [sp, #184]
    ldr x10, [sp, #184]
    eor x9, x9, x10
    str x9, [sp, #192]
    movz x9, #1
    ldr x10, [sp, #184]
    movz x11, #9
    cmp x9, xzr
    csel x10, x10, x11, ne
    str x10, [sp, #200]
    ldr x0, [sp, #200]
    b .Lf_epilogue
.Lf_epilogue:
    add sp, sp, #208
    ldp x29, x30, [sp], #16
    ret


