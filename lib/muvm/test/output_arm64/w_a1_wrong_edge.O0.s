# ========================================================
# Module: a1_wrong_edge
# Target: AArch64 / AAPCS64
# ========================================================

# ---- Global Variables ----
    .data
    .align 4
.globl gx
gx:
    .long 3
    .data
    .align 4
.globl gy
gy:
    .long 10

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
.Lmain_BB6:
    adrp x9, gx
    add x9, x9, :lo12:gx
    ldr w10, [x9]
    str x10, [sp, #136]
    adrp x9, gy
    add x9, x9, :lo12:gy
    ldr w10, [x9]
    str x10, [sp, #144]
    ldr x9, [sp, #136]
    ldr x10, [sp, #144]
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #152]
    ldr x9, [sp, #152]
    cbz x9, .Lmain_cse_13
    b .Lmain_BB7
.Lmain_cse_13:
    b .Lmain_BB8
.Lmain_BB7:
    ldr x9, [sp, #136]
    ldr x10, [sp, #144]
    cmp x9, x10
    cset w9, ge
    str x9, [sp, #160]
    ldr x9, [sp, #160]
    cbz x9, .Lmain_cse_15
    b .Lmain_BB8
.Lmain_cse_15:
    b .Lmain_BB9
.Lmain_BB8:
    movz x0, #2
    b .Lmain_epilogue
.Lmain_BB9:
    movz x0, #1
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #176
    ldp x29, x30, [sp], #16
    ret


