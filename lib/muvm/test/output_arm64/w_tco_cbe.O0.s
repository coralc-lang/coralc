# ========================================================
# Module: e8
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @inf
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl inf
inf:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
    str x0, [sp, #136]
.Linf_BB3:
    ldr x0, [sp, #136]
    bl inf
    str x0, [sp, #144]
    ldr x9, [sp, #144]
    ldr x10, [sp, #136]
    add x9, x9, x10
    str x9, [sp, #152]
    ldr x0, [sp, #152]
    b .Linf_epilogue
.Linf_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 144 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #144
.Lmain_BB8:
    mov x0, xzr
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #144
    ldp x29, x30, [sp], #16
    ret


