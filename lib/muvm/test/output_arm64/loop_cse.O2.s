# ========================================================
# Module: loopcse_demo
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @lc_invariant
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 288 bytes
# ========================================================
    .text
.globl lc_invariant
lc_invariant:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #288
    str x0, [sp, #136]
.Llc_invariant_BB3:
    add x9, sp, #184
    str x9, [sp, #176]
    ldr x9, [sp, #176]
    str x9, [sp, #184]
    movz x9, #30
    ldr x10, [sp, #184]
    str x9, [x10]
    ldr x9, [sp, #176]
    add x9, x9, #8
    str x9, [sp, #192]
    movz x9, #40
    ldr x10, [sp, #192]
    str x9, [x10]
    ldr x9, [sp, #176]
    add x9, x9, #16
    str x9, [sp, #200]
    movz x9, #50
    ldr x10, [sp, #200]
    str x9, [x10]
    ldr x9, [sp, #176]
    add x9, x9, #24
    str x9, [sp, #208]
    movz x9, #60
    ldr x10, [sp, #208]
    str x9, [x10]
    ldr x9, [sp, #184]
    ldr x10, [x9]
    str x10, [sp, #216]
    ldr x9, [sp, #216]
    movz x10, #7
    add x9, x9, x10
    str x9, [sp, #224]
    ldr x9, [sp, #224]
    movz x10, #3
    mul x9, x9, x10
    str x9, [sp, #232]
    mov x9, xzr
    str x9, [sp, #240]
    mov x9, xzr
    str x9, [sp, #248]
    b .Llc_invariant_BB4
.Llc_invariant_BB4:
    ldr x9, [sp, #248]
    ldr x10, [sp, #232]
    add x9, x9, x10
    str x9, [sp, #256]
    b .Llc_invariant_BB5
.Llc_invariant_BB5:
    ldr x9, [sp, #240]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #264]
    ldr x9, [sp, #264]
    ldr x10, [sp, #136]
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #272]
    ldr x9, [sp, #272]
    cbz x9, .Llc_invariant_cse_36
    ldr x9, [sp, #264]
    str x9, [sp, #240]
    ldr x9, [sp, #256]
    str x9, [sp, #248]
    b .Llc_invariant_BB4
.Llc_invariant_cse_36:
    b .Llc_invariant_BB6
.Llc_invariant_BB6:
    ldr x0, [sp, #256]
    b .Llc_invariant_epilogue
.Llc_invariant_epilogue:
    add sp, sp, #288
    ldp x29, x30, [sp], #16
    ret


