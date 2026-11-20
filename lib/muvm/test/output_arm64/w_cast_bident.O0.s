# ========================================================
# Module: cast_bident
# Target: AArch64 / AAPCS64
# ========================================================

# ---- Global Variables ----
    .data
    .align 8
.globl g
g:
    .quad 6

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
.Lmain_BB4:
    adrp x9, g
    add x9, x9, :lo12:g
    ldr x10, [x9]
    str x10, [sp, #136]
    ldr x9, [sp, #136]
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #152]
    ldr x9, [sp, #152]
    str x9, [sp, #160]
    ldr x0, [sp, #160]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #176
    ldp x29, x30, [sp], #16
    ret


