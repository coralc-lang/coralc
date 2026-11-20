# ========================================================
# Module: asm_mem
# Target: AArch64 / AAPCS64
# ========================================================

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
.Lmain_BB2:
    add x9, sp, #136
    str x9, [sp, #128]
    add x9, sp, #152
    str x9, [sp, #144]
    movz x9, #7
    ldr x10, [sp, #128]
    str x9, [x10]
    str x19, [sp, #0]
    ldr x19, [sp, #144]
    ldr x10, [sp, #128]
    movq [x10], %x9
    addq $1, %x9
    str x9, [x19]
    ldr x19, [sp, #0]
    ldr x9, [sp, #144]
    ldr x10, [x9]
    str x10, [sp, #168]
    ldr x9, [sp, #168]
    str x9, [sp, #176]
    ldr x0, [sp, #176]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #192
    ldp x29, x30, [sp], #16
    ret


