# ========================================================
# Module: structs
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 224 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #224
.Lmain_BB2:
    add x9, sp, #136
    str x9, [sp, #128]
    ldr x9, [sp, #128]
    str x9, [sp, #160]
    ldr x9, [sp, #128]
    add x9, x9, #8
    str x9, [sp, #168]
    movz x9, #7
    ldr x10, [sp, #160]
    str w9, [x10]
    movz x9, #50
    ldr x10, [sp, #168]
    str x9, [x10]
    ldr x9, [sp, #160]
    ldr w10, [x9]
    str x10, [sp, #176]
    ldr x9, [sp, #176]
    uxtw x9, w9
    str x9, [sp, #184]
    ldr x9, [sp, #168]
    ldr x10, [x9]
    str x10, [sp, #192]
    ldr x9, [sp, #184]
    ldr x10, [sp, #192]
    add x9, x9, x10
    str x9, [sp, #200]
    ldr x9, [sp, #200]
    str x9, [sp, #208]
    ldr x0, [sp, #208]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #224
    ldp x29, x30, [sp], #16
    ret


