# ========================================================
# Module: array_sum
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 288 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #288
.Lmain_BB2:
    add x9, sp, #136
    str x9, [sp, #128]
    mov x9, xzr
    str x9, [sp, #184]
    b .Lmain_BB3
.Lmain_BB3:
    ldr x9, [sp, #184]
    movz x10, #5
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #192]
    ldr x9, [sp, #192]
    cbz x9, .Lmain_cse_17
    b .Lmain_BB4
.Lmain_cse_17:
    mov x9, xzr
    str x9, [sp, #216]
    mov x9, xzr
    str x9, [sp, #224]
    b .Lmain_BB6
.Lmain_BB4:
    ldr x9, [sp, #128]
    ldr x10, [sp, #184]
    movz x11, #8
    mul x10, x10, x11
    add x9, x9, x10
    str x9, [sp, #200]
    ldr x9, [sp, #184]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #208]
    ldr x9, [sp, #208]
    ldr x10, [sp, #200]
    str x9, [x10]
    ldr x9, [sp, #208]
    str x9, [sp, #184]
    b .Lmain_BB3
.Lmain_BB6:
    ldr x9, [sp, #224]
    movz x10, #5
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #232]
    ldr x9, [sp, #232]
    cbz x9, .Lmain_cse_33
    b .Lmain_BB7
.Lmain_cse_33:
    b .Lmain_BB8
.Lmain_BB7:
    ldr x9, [sp, #128]
    ldr x10, [sp, #224]
    movz x11, #8
    mul x10, x10, x11
    add x9, x9, x10
    str x9, [sp, #240]
    ldr x9, [sp, #240]
    ldr x10, [x9]
    str x10, [sp, #248]
    ldr x9, [sp, #216]
    ldr x10, [sp, #248]
    add x9, x9, x10
    str x9, [sp, #256]
    ldr x9, [sp, #224]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #264]
    ldr x9, [sp, #256]
    str x9, [sp, #216]
    ldr x9, [sp, #264]
    str x9, [sp, #224]
    b .Lmain_BB6
.Lmain_BB8:
    ldr x9, [sp, #216]
    str x9, [sp, #272]
    ldr x0, [sp, #272]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #288
    ldp x29, x30, [sp], #16
    ret


