# ========================================================
# Module: if_else_phi
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 176 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #176
.Lmain_BB2:
    movz x9, #7
    movz x10, #5
    cmp x9, x10
    cset w9, gt
    str x9, [sp, #136]
    ldr x9, [sp, #136]
    cbz x9, .Lmain_cse_12
    b .Lmain_BB3
.Lmain_cse_12:
    b .Lmain_BB4
.Lmain_BB3:
    movz x9, #7
    movz x10, #2
    mul x9, x9, x10
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    str x9, [sp, #160]
    b .Lmain_BB5
.Lmain_BB4:
    mov x9, xzr
    movz x10, #7
    sub x9, x9, x10
    str x9, [sp, #152]
    ldr x9, [sp, #152]
    str x9, [sp, #160]
    b .Lmain_BB5
.Lmain_BB5:
    ldr x9, [sp, #160]
    str x9, [sp, #168]
    ldr x0, [sp, #168]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #176
    ldp x29, x30, [sp], #16
    ret


