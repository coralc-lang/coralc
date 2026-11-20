# ========================================================
# Module: atomic_ops
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 208 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #208
.Lmain_BB2:
    add x9, sp, #136
    str x9, [sp, #128]
    movz x9, #5
    ldr x10, [sp, #128]
    str x9, [x10]
    ldr x9, [sp, #128]
    movz x10, #6
.Lmain_atom_7:
    ldaxr x11, [x9]
    add x14, x11, x10
    stlxr w15, x14, [x9]
    cbnz w15, .Lmain_atom_7
    str x11, [sp, #152]
    ldr x9, [sp, #128]
    ldr x10, [x9]
    str x10, [sp, #160]
    ldr x9, [sp, #160]
    str x9, [sp, #168]
    ldr x9, [sp, #152]
    str x9, [sp, #176]
    ldr x9, [sp, #168]
    ldr x10, [sp, #176]
    add x9, x9, x10
    str x9, [sp, #184]
    ldr x9, [sp, #184]
    movz x10, #6
    sub x9, x9, x10
    str x9, [sp, #192]
    ldr x0, [sp, #192]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #208
    ldp x29, x30, [sp], #16
    ret


