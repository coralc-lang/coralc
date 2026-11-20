# ========================================================
# Module: licmparam
# Target: AArch64 / AAPCS64
# ========================================================

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
.Lmain_BB2:
    movz x0, #6
    bl invariant_square
    str x0, [sp, #136]
    ldr x9, [sp, #136]
    str x9, [sp, #144]
    ldr x0, [sp, #144]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @invariant_square
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 192 bytes
# ========================================================
    .text
.globl invariant_square
invariant_square:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #192
    str x0, [sp, #136]
.Linvariant_square_BB9:
    mov x9, xzr
    str x9, [sp, #144]
    mov x9, xzr
    str x9, [sp, #152]
    b .Linvariant_square_BB10
.Linvariant_square_BB10:
    ldr x9, [sp, #144]
    movz x10, #7
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #160]
    ldr x9, [sp, #160]
    cbz x9, .Linvariant_square_cse_19
    b .Linvariant_square_BB11
.Linvariant_square_cse_19:
    b .Linvariant_square_BB12
.Linvariant_square_BB11:
    ldr x9, [sp, #136]
    ldr x10, [sp, #136]
    mul x9, x9, x10
    str x9, [sp, #168]
    ldr x9, [sp, #144]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #176]
    ldr x9, [sp, #152]
    ldr x10, [sp, #168]
    add x9, x9, x10
    str x9, [sp, #184]
    ldr x9, [sp, #176]
    str x9, [sp, #144]
    ldr x9, [sp, #184]
    str x9, [sp, #152]
    b .Linvariant_square_BB10
.Linvariant_square_BB12:
    ldr x0, [sp, #152]
    b .Linvariant_square_epilogue
.Linvariant_square_epilogue:
    add sp, sp, #192
    ldp x29, x30, [sp], #16
    ret


