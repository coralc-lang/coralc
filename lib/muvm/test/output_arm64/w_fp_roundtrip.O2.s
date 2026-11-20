# ========================================================
# Module: fp_roundtrip
# Target: AArch64 / AAPCS64
# ========================================================

# ---- Global Variables ----
    .data
    .align 8
.globl g
g:
    .quad 4609434218613702656

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
    fmov d0, x9
    fcvtzs x9, d0
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    scvtf d0, x9
    fmov x9, d0
    str x9, [sp, #152]
    ldr x9, [sp, #152]
    ldr x10, [sp, #136]
    fmov d0, x9
    fmov d1, x10
    fcmp d0, d1
    cset w9, eq
    str x9, [sp, #160]
    ldr x9, [sp, #160]
    and x9, x9, #255
    str x9, [sp, #168]
    ldr x0, [sp, #168]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #176
    ldp x29, x30, [sp], #16
    ret


