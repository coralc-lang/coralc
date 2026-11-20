# ========================================================
# Module: parsed
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 240 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #240
.Lmain_BB2:
    add x9, sp, #136
    str x9, [sp, #128]
    add x9, sp, #152
    str x9, [sp, #144]
    add x9, sp, #168
    str x9, [sp, #160]
    mov x9, xzr
    ldr x10, [sp, #128]
    str x9, [x10]
    movz x9, #5
    ldr x10, [sp, #144]
    str x9, [x10]
    movz x9, #1
    ldr x10, [sp, #160]
    str x9, [x10]
    movz x9, #1
    ldr x10, [sp, #160]
    strb w9, [x10]
    ldr x9, [sp, #160]
    ldr x10, [x9]
    str x10, [sp, #184]
    ldr x9, [sp, #184]
    mov x10, xzr
    cmp x9, x10
    cset w9, gt
    str x9, [sp, #192]
    ldr x9, [sp, #192]
    cbz x9, .Lmain_cse_19
    b .Lmain_BB4
.Lmain_cse_19:
    b .Lmain_BB3
.Lmain_BB3:
    movz x9, #10
    ldr x10, [sp, #128]
    str x9, [x10]
    ldr x9, [sp, #128]
    str x9, [sp, #200]
    b .Lmain_BB5
.Lmain_BB4:
    movz x9, #20
    ldr x10, [sp, #144]
    str x9, [x10]
    ldr x9, [sp, #144]
    str x9, [sp, #200]
    b .Lmain_BB5
.Lmain_BB5:
    ldr x9, [sp, #200]
    ldr x10, [x9]
    str x10, [sp, #208]
    movz x9, #30
    ldr x10, [sp, #144]
    str x9, [x10]
    ldr x9, [sp, #200]
    ldr x10, [x9]
    str x10, [sp, #216]
    ldr x9, [sp, #208]
    ldr x10, [sp, #216]
    add x9, x9, x10
    str x9, [sp, #224]
    ldr x9, [sp, #224]
    str x9, [sp, #232]
    ldr x0, [sp, #232]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #240
    ldp x29, x30, [sp], #16
    ret


