# ========================================================
# Module: adceunreach
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @g
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl g
g:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
    mov w9, w0
    str x9, [sp, #136]
.Lg_BB3:
    b .Lg_BB5
.Lg_BB4:
    movz x0, #99
    b .Lg_epilogue
.Lg_BB5:
    ldr x0, [sp, #136]
    b .Lg_epilogue
.Lg_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret


