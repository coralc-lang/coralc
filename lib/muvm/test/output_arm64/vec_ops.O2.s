# ========================================================
# Module: vec_ops
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 256 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #256
.Lmain_BB2:
    movz x9, #3
    str w9, [sp, #144]
    str w9, [sp, #148]
    str w9, [sp, #152]
    str w9, [sp, #156]
    movz x9, #7
    str w9, [sp, #160]
    str w9, [sp, #164]
    str w9, [sp, #168]
    str w9, [sp, #172]
    ldr w9, [sp, #144]
    ldr w10, [sp, #160]
    add x9, x9, x10
    str w9, [sp, #176]
    ldr w9, [sp, #148]
    ldr w10, [sp, #164]
    add x9, x9, x10
    str w9, [sp, #180]
    ldr w9, [sp, #152]
    ldr w10, [sp, #168]
    add x9, x9, x10
    str w9, [sp, #184]
    ldr w9, [sp, #156]
    ldr w10, [sp, #172]
    add x9, x9, x10
    str w9, [sp, #188]
    ldr w9, [sp, #176]
    ldr w10, [sp, #160]
    cmp x9, x10
    csel x9, x10, x9, gt
    str w9, [sp, #192]
    ldr w9, [sp, #180]
    ldr w10, [sp, #164]
    cmp x9, x10
    csel x9, x10, x9, gt
    str w9, [sp, #196]
    ldr w9, [sp, #184]
    ldr w10, [sp, #168]
    cmp x9, x10
    csel x9, x10, x9, gt
    str w9, [sp, #200]
    ldr w9, [sp, #188]
    ldr w10, [sp, #172]
    cmp x9, x10
    csel x9, x10, x9, gt
    str w9, [sp, #204]
    ldr x9, [sp, #192]
    str x9, [sp, #208]
    ldr x9, [sp, #200]
    str x9, [sp, #216]
    movz x11, #30
    str w11, [sp, #216]
    ldr w9, [sp, #216]
    str x9, [sp, #216]
    ldr w9, [sp, #216]
    str w9, [sp, #232]
    ldr w9, [sp, #212]
    str w9, [sp, #236]
    ldr w9, [sp, #208]
    str w9, [sp, #240]
    ldr w9, [sp, #220]
    str w9, [sp, #244]
    ldr w9, [sp, #236]
    str x9, [sp, #240]
    ldr x9, [sp, #216]
    ldr x10, [sp, #240]
    add x9, x9, x10
    str x9, [sp, #248]
    ldr x0, [sp, #248]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #256
    ldp x29, x30, [sp], #16
    ret


