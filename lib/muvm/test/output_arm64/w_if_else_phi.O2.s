# ========================================================
# Module: if_else_phi
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 144 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #144
.Lmain_BB2:
    b .Lmain_BB5
.Lmain_BB5:
    movz x0, #14
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #144
    ldp x29, x30, [sp], #16
    ret


