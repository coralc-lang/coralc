# ========================================================
# Module: floats
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 224 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #224
.Lmain_BB2:
    movz x9, #7
    scvtf d0, w9
    fmov x9, d0
    str x9, [sp, #136]
    ldr x9, [sp, #136]
    fmov d0, x9
    fcvtzs w9, d0
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    scvtf s0, w9
    fmov w9, s0
    str x9, [sp, #152]
    ldr x9, [sp, #152]
    fmov s0, w9
    fcvtzs w9, s0
    str x9, [sp, #160]
    ldr x9, [sp, #160]
    ucvtf d0, w9
    fmov x9, d0
    str x9, [sp, #168]
    ldr x9, [sp, #168]
    fmov d0, x9
    fcvtzu w9, d0
    str x9, [sp, #176]
    movz x9, #2
    scvtf d0, x9
    fmov x9, d0
    str x9, [sp, #184]
    ldr x9, [sp, #184]
    fmov d0, x9
    fcvtzs x9, d0
    str x9, [sp, #192]
    ldr x9, [sp, #192]
    str x9, [sp, #200]
    ldr x9, [sp, #176]
    ldr x10, [sp, #200]
    add x9, x9, x10
    str x9, [sp, #208]
    ldr x0, [sp, #208]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #224
    ldp x29, x30, [sp], #16
    ret


