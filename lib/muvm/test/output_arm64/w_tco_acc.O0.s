# ========================================================
# Module: tco_acc
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @sumto
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ ]
# Stack Frame: 192 bytes
# ========================================================
    .text
.globl sumto
sumto:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #192
    str x0, [sp, #136]
.Lsumto_BB3:
    ldr x9, [sp, #136]
    mov x10, xzr
    cmp x9, x10
    cset w9, le
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    cbz x9, .Lsumto_cse_8
    b .Lsumto_BB4
.Lsumto_cse_8:
    b .Lsumto_BB5
.Lsumto_BB4:
    mov x0, xzr
    b .Lsumto_epilogue
.Lsumto_BB5:
    ldr x9, [sp, #136]
    movz x10, #1
    sub x9, x9, x10
    str x9, [sp, #160]
    ldr x0, [sp, #160]
    bl sumto
    str x0, [sp, #168]
    ldr x9, [sp, #168]
    ldr x10, [sp, #136]
    add x9, x9, x10
    str x9, [sp, #176]
    ldr x0, [sp, #176]
    b .Lsumto_epilogue
.Lsumto_epilogue:
    add sp, sp, #192
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
.Lmain_BB16:
    movz x0, #5
    bl sumto
    str x0, [sp, #136]
    ldr x9, [sp, #136]
    str x9, [sp, #144]
    ldr x0, [sp, #144]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret


