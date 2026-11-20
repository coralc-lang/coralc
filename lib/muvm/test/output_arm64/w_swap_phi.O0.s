# ========================================================
# Module: swap_phi
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 208 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #208
.Lmain_BB2:
    movz x9, #1
    str x9, [sp, #136]
    movz x9, #2
    str x9, [sp, #144]
    mov x9, xzr
    str x9, [sp, #152]
    b .Lmain_BB3
.Lmain_BB3:
    ldr x9, [sp, #152]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #160]
    ldr x9, [sp, #160]
    movz x10, #4
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #168]
    ldr x9, [sp, #168]
    cbz x9, .Lmain_cse_15
    ldr x9, [sp, #144]
    str x9, [sp, #64]
    ldr x9, [sp, #136]
    str x9, [sp, #72]
    ldr x9, [sp, #64]
    str x9, [sp, #136]
    ldr x9, [sp, #72]
    str x9, [sp, #144]
    ldr x9, [sp, #160]
    str x9, [sp, #152]
    b .Lmain_BB3
.Lmain_cse_15:
    b .Lmain_BB4
.Lmain_BB4:
    ldr x9, [sp, #136]
    movz x10, #10
    mul x9, x9, x10
    str x9, [sp, #176]
    ldr x9, [sp, #176]
    ldr x10, [sp, #144]
    add x9, x9, x10
    str x9, [sp, #184]
    ldr x9, [sp, #184]
    str x9, [sp, #192]
    ldr x0, [sp, #192]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #208
    ldp x29, x30, [sp], #16
    ret


