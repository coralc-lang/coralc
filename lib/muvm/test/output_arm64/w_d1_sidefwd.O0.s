# ========================================================
# Module: d1_sidefwd
# Target: AArch64 / AAPCS64
# ========================================================

# ---- Global Variables ----
    .data
    .align 8
.globl holder
holder:
    .quad 0
    .data
    .align 4
.globl input
input:
    .long 1

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
.Lmain_BB6:
    add x9, sp, #136
    str x9, [sp, #128]
    movz x9, #42
    ldr x10, [sp, #128]
    str w9, [x10]
    ldr x9, [sp, #128]
    adrp x10, holder
    add x10, x10, :lo12:holder
    str x9, [x10]
    adrp x9, input
    add x9, x9, :lo12:input
    ldr w10, [x9]
    str x10, [sp, #152]
    ldr x9, [sp, #152]
    mov x10, xzr
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #160]
    ldr x9, [sp, #160]
    cbz x9, .Lmain_cse_16
    b .Lmain_BB7
.Lmain_cse_16:
    b .Lmain_BB8
.Lmain_BB7:
    movz x9, #99
    ldr x10, [sp, #128]
    str w9, [x10]
    mov x0, xzr
    b .Lmain_epilogue
.Lmain_BB8:
    ldr x9, [sp, #128]
    ldr w10, [x9]
    str x10, [sp, #176]
    ldr x0, [sp, #176]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #192
    ldp x29, x30, [sp], #16
    ret


