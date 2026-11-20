# ========================================================
# Module: a3_unguarded_range
# Target: AArch64 / AAPCS64
# ========================================================

# ---- Global Variables ----
    .data
    .align 4
.globl g
g:
    .long 0

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
.Lmain_BB4:
    b .Lmain_BB5
.Lmain_BB5:
    adrp x9, g
    add x9, x9, :lo12:g
    ldr w10, [x9]
    str x10, [sp, #136]
    ldr x9, [sp, #136]
    movz x10, #50
    cmp x9, x10
    cset w9, ge
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    cbz x9, .Lmain_cse_14
    b .Lmain_BB6
.Lmain_cse_14:
    b .Lmain_BB7
.Lmain_BB6:
    movz x0, #7
    b .Lmain_epilogue
.Lmain_BB7:
    movz x0, #3
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret


