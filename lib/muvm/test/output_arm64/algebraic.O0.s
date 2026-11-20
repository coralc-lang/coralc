# ========================================================
# Module: algebraic_demo
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @mul_pow2
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 192 bytes
# ========================================================
    .text
.globl mul_pow2
mul_pow2:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #192
    str x0, [sp, #136]
    str x1, [sp, #144]
.Lmul_pow2_BB4:
    ldr x9, [sp, #136]
    movz x10, #16
    mul x9, x9, x10
    str x9, [sp, #152]
    ldr x9, [sp, #136]
    movz x10, #2
    mul x9, x9, x10
    str x9, [sp, #160]
    ldr x9, [sp, #144]
    movz x10, #8
    mul x9, x9, x10
    str x9, [sp, #168]
    ldr x9, [sp, #152]
    ldr x10, [sp, #160]
    add x9, x9, x10
    str x9, [sp, #176]
    ldr x9, [sp, #176]
    ldr x10, [sp, #168]
    add x9, x9, x10
    str x9, [sp, #184]
    ldr x0, [sp, #184]
    b .Lmul_pow2_epilogue
.Lmul_pow2_epilogue:
    add sp, sp, #192
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @udiv_1
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl udiv_1
udiv_1:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
    str x0, [sp, #136]
.Ludiv_1_BB16:
    ldr x9, [sp, #136]
    movz x10, #1
    udiv x9, x9, x10
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    movz x10, #4
    udiv x9, x9, x10
    str x9, [sp, #152]
    ldr x0, [sp, #152]
    b .Ludiv_1_epilogue
.Ludiv_1_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @urem_1
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl urem_1
urem_1:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
    str x0, [sp, #136]
.Lurem_1_BB24:
    ldr x9, [sp, #136]
    movz x10, #1
    udiv x11, x9, x10
    msub x9, x10, x11, x9
    str x9, [sp, #144]
    ldr x0, [sp, #144]
    b .Lurem_1_epilogue
.Lurem_1_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @smin_same
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 176 bytes
# ========================================================
    .text
.globl smin_same
smin_same:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #176
    str x0, [sp, #136]
.Lsmin_same_BB29:
    ldr x9, [sp, #136]
    ldr x10, [sp, #136]
    cmp x9, x10
    csel x9, x10, x9, gt
    str x9, [sp, #144]
    ldr x9, [sp, #136]
    ldr x10, [sp, #136]
    cmp x9, x10
    csel x9, x10, x9, gt
    str x9, [sp, #152]
    ldr x9, [sp, #144]
    ldr x10, [sp, #152]
    add x9, x9, x10
    str x9, [sp, #160]
    ldr x0, [sp, #160]
    b .Lsmin_same_epilogue
.Lsmin_same_epilogue:
    add sp, sp, #176
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @lex_chain
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 192 bytes
# ========================================================
    .text
.globl lex_chain
lex_chain:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #192
    str x0, [sp, #136]
    str x1, [sp, #144]
    str x2, [sp, #152]
.Llex_chain_BB38:
    ldr x9, [sp, #144]
    movz x10, #4
    add x9, x9, x10
    str x9, [sp, #160]
    ldr x9, [sp, #136]
    ldr x10, [sp, #160]
    add x9, x9, x10
    str x9, [sp, #168]
    ldr x9, [sp, #152]
    ldr x10, [sp, #168]
    add x9, x9, x10
    str x9, [sp, #176]
    ldr x0, [sp, #176]
    b .Llex_chain_epilogue
.Llex_chain_epilogue:
    add sp, sp, #192
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @ext_chain
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl ext_chain
ext_chain:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
    mov w9, w0
    str x9, [sp, #136]
.Lext_chain_BB45:
    ldr x9, [sp, #136]
    sxtw x9, w9
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    str x9, [sp, #152]
    ldr x0, [sp, #152]
    b .Lext_chain_epilogue
.Lext_chain_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret


