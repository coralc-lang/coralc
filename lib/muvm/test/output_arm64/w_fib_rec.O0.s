# ========================================================
# Module: fib_rec
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @fib
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ ]
# Stack Frame: 208 bytes
# ========================================================
    .text
.globl fib
fib:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #208
    str x0, [sp, #136]
.Lfib_BB3:
    ldr x9, [sp, #136]
    movz x10, #2
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    cbz x9, .Lfib_cse_8
    b .Lfib_BB4
.Lfib_cse_8:
    b .Lfib_BB5
.Lfib_BB4:
    ldr x0, [sp, #136]
    b .Lfib_epilogue
.Lfib_BB5:
    ldr x9, [sp, #136]
    movz x10, #1
    sub x9, x9, x10
    str x9, [sp, #160]
    ldr x9, [sp, #136]
    movz x10, #2
    sub x9, x9, x10
    str x9, [sp, #168]
    ldr x0, [sp, #160]
    bl fib
    str x0, [sp, #176]
    ldr x0, [sp, #168]
    bl fib
    str x0, [sp, #184]
    ldr x9, [sp, #176]
    ldr x10, [sp, #184]
    add x9, x9, x10
    str x9, [sp, #192]
    ldr x0, [sp, #192]
    b .Lfib_epilogue
.Lfib_epilogue:
    add sp, sp, #208
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
.Lmain_BB18:
    movz x0, #10
    bl fib
    str x0, [sp, #136]
    ldr x9, [sp, #136]
    str x9, [sp, #144]
    ldr x0, [sp, #144]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret


