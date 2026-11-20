# ========================================================
# Module: gcd
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
    movz x9, #18
    str x9, [sp, #136]
    movz x9, #48
    str x9, [sp, #144]
    b .Lmain_BB3
.Lmain_BB3:
    ldr x9, [sp, #136]
    mov x10, xzr
    cmp x9, x10
    cset w9, ne
    str x9, [sp, #152]
    ldr x9, [sp, #152]
    cbz x9, .Lmain_cse_16
    b .Lmain_BB4
.Lmain_cse_16:
    b .Lmain_BB5
.Lmain_BB4:
    ldr x9, [sp, #144]
    ldr x10, [sp, #136]
    sdiv x11, x9, x10
    msub x9, x10, x11, x9
    str x9, [sp, #160]
    ldr x9, [sp, #136]
    str x9, [sp, #64]
    ldr x9, [sp, #160]
    str x9, [sp, #136]
    ldr x9, [sp, #64]
    str x9, [sp, #144]
    b .Lmain_BB3
.Lmain_BB5:
    ldr x9, [sp, #144]
    str x9, [sp, #168]
    ldr x0, [sp, #168]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #176
    ldp x29, x30, [sp], #16
    ret


