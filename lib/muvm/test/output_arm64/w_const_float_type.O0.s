# ========================================================
# Module: const_float_type
# Target: AArch64 / AAPCS64
# ========================================================

# ---- Global Variables ----
    .data
    .align 4
.globl g
g:
    .long 3

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
.Lmain_BB4:
    movz x9, #0
    movk x9, #16256, lsl #16
    movz x10, #0
    movk x10, #16384, lsl #16
    fmov s0, w9
    fmov s1, w10
    fadd s0, s0, s1
    fmov w9, s0
    str x9, [sp, #136]
    ldr x9, [sp, #136]
    fmov s0, w9
    fcvtzs w9, s0
    str x9, [sp, #144]
    adrp x9, g
    add x9, x9, :lo12:g
    ldr w10, [x9]
    str x10, [sp, #152]
    ldr x9, [sp, #152]
    scvtf d0, w9
    fmov x9, d0
    str x9, [sp, #160]
    movz x9, #0
    movk x9, #16368, lsl #48
    ldr x10, [sp, #160]
    fmov d0, x9
    fmov d1, x10
    fadd d0, d0, d1
    fmov x9, d0
    str x9, [sp, #168]
    ldr x9, [sp, #168]
    fmov d0, x9
    fcvtzs w9, d0
    str x9, [sp, #176]
    ldr x9, [sp, #144]
    ldr x10, [sp, #176]
    add x9, x9, x10
    str x9, [sp, #184]
    ldr x0, [sp, #184]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #192
    ldp x29, x30, [sp], #16
    ret


