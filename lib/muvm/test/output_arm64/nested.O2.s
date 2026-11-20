# ========================================================
# Module: nested
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
    mov x9, xzr
    str x9, [sp, #136]
    mov x9, xzr
    str x9, [sp, #144]
    b .Lmain_BB3
.Lmain_BB3:
    ldr x9, [sp, #144]
    movz x10, #4
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #152]
    ldr x9, [sp, #144]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #160]
    ldr x9, [sp, #152]
    cbz x9, .Lmain_cse_18
    mov x9, xzr
    str x9, [sp, #168]
    ldr x9, [sp, #136]
    str x9, [sp, #176]
    b .Lmain_BB5
.Lmain_cse_18:
    b .Lmain_BB8
.Lmain_BB5:
    ldr x9, [sp, #168]
    movz x10, #3
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #184]
    ldr x9, [sp, #184]
    cbz x9, .Lmain_cse_25
    b .Lmain_BB6
.Lmain_cse_25:
    ldr x9, [sp, #176]
    str x9, [sp, #136]
    ldr x9, [sp, #160]
    str x9, [sp, #144]
    b .Lmain_BB3
.Lmain_BB6:
    ldr x9, [sp, #144]
    ldr x10, [sp, #168]
    mul x9, x9, x10
    str x9, [sp, #192]
    ldr x9, [sp, #176]
    ldr x10, [sp, #192]
    add x9, x9, x10
    str x9, [sp, #200]
    ldr x9, [sp, #168]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #208]
    ldr x9, [sp, #208]
    str x9, [sp, #168]
    ldr x9, [sp, #200]
    str x9, [sp, #176]
    b .Lmain_BB5
.Lmain_BB8:
    ldr x9, [sp, #136]
    str x9, [sp, #216]
    ldr x0, [sp, #216]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #224
    ldp x29, x30, [sp], #16
    ret


