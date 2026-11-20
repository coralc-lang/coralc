# ========================================================
# Module: asm_add
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
    add x9, sp, #136
    str x9, [sp, #128]
    movz x9, #40
    ldr x10, [sp, #128]
    str x9, [x10]
    str x19, [sp, #0]
    ldr x19, [sp, #128]
    ldr x9, [x19]
    movz x10, #2
    addq %x10, %x9
    str x9, [x19]
    ldr x19, [sp, #0]
    ldr x9, [sp, #128]
    ldr x10, [x9]
    str x10, [sp, #152]
    ldr x9, [sp, #152]
    str x9, [sp, #160]
    ldr x0, [sp, #160]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #176
    ldp x29, x30, [sp], #16
    ret


