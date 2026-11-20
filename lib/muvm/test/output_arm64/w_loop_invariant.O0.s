# ========================================================
# Module: loop_invariant
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 192 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #192
.Lmain_BB2:
    mov x9, xzr
    str x9, [sp, #136]
    mov x9, xzr
    str x9, [sp, #144]
    b .Lmain_BB3
.Lmain_BB3:
    ldr x9, [sp, #144]
    movz x10, #10
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #152]
    ldr x9, [sp, #152]
    cbz x9, .Lmain_cse_15
    b .Lmain_BB4
.Lmain_cse_15:
    b .Lmain_BB5
.Lmain_BB4:
    movz x9, #3
    movz x10, #7
    mul x9, x9, x10
    str x9, [sp, #160]
    ldr x9, [sp, #136]
    ldr x10, [sp, #160]
    add x9, x9, x10
    str x9, [sp, #168]
    ldr x9, [sp, #144]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #176]
    ldr x9, [sp, #168]
    str x9, [sp, #136]
    ldr x9, [sp, #176]
    str x9, [sp, #144]
    b .Lmain_BB3
.Lmain_BB5:
    ldr x9, [sp, #136]
    str x9, [sp, #184]
    ldr x0, [sp, #184]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #192
    ldp x29, x30, [sp], #16
    ret


