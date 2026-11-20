# ========================================================
# Module: lc_invariant2
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @run
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 272 bytes
# ========================================================
    .text
.globl run
run:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #272
    str x0, [sp, #136]
.Lrun_BB3:
    add x9, sp, #184
    str x9, [sp, #176]
    ldr x9, [sp, #176]
    str x9, [sp, #184]
    movz x9, #99
    ldr x10, [sp, #184]
    str x9, [x10]
    mov x9, xzr
    str x9, [sp, #192]
    mov x9, xzr
    str x9, [sp, #200]
    b .Lrun_BB4
.Lrun_BB4:
    ldr x9, [sp, #176]
    str x9, [sp, #208]
    ldr x9, [sp, #208]
    ldr x10, [x9]
    str x10, [sp, #216]
    ldr x9, [sp, #216]
    movz x10, #7
    add x9, x9, x10
    str x9, [sp, #224]
    ldr x9, [sp, #224]
    movz x10, #2
    mul x9, x9, x10
    str x9, [sp, #232]
    ldr x9, [sp, #200]
    ldr x10, [sp, #232]
    add x9, x9, x10
    str x9, [sp, #240]
    b .Lrun_BB5
.Lrun_BB5:
    ldr x9, [sp, #192]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #248]
    ldr x9, [sp, #248]
    ldr x10, [sp, #136]
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #256]
    ldr x9, [sp, #256]
    cbz x9, .Lrun_cse_26
    ldr x9, [sp, #248]
    str x9, [sp, #192]
    ldr x9, [sp, #240]
    str x9, [sp, #200]
    b .Lrun_BB4
.Lrun_cse_26:
    b .Lrun_BB6
.Lrun_BB6:
    ldr x0, [sp, #240]
    b .Lrun_epilogue
.Lrun_epilogue:
    add sp, sp, #272
    ldp x29, x30, [sp], #16
    ret


