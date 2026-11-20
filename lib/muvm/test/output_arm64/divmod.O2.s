# ========================================================
# Module: divmod_demo
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @divrem3
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 208 bytes
# ========================================================
    .text
.globl divrem3
divrem3:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #208
    str x0, [sp, #136]
    str x1, [sp, #144]
.Ldivrem3_BB4:
    ldr x9, [sp, #136]
    ldr x10, [sp, #144]
    sdiv x9, x9, x10
    str x9, [sp, #152]
    ldr x9, [sp, #152]
    movz x10, #10
    mul x9, x9, x10
    str x9, [sp, #160]
    ldr x9, [sp, #152]
    ldr x10, [sp, #160]
    add x9, x9, x10
    str x9, [sp, #168]
    ldr x9, [sp, #152]
    ldr x10, [sp, #144]
    mul x9, x9, x10
    str x9, [sp, #176]
    ldr x9, [sp, #136]
    ldr x10, [sp, #176]
    sub x9, x9, x10
    str x9, [sp, #184]
    ldr x9, [sp, #168]
    ldr x10, [sp, #184]
    add x9, x9, x10
    str x9, [sp, #192]
    ldr x0, [sp, #192]
    b .Ldivrem3_epilogue
.Ldivrem3_epilogue:
    add sp, sp, #208
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @urem_fused3
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 208 bytes
# ========================================================
    .text
.globl urem_fused3
urem_fused3:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #208
    str x0, [sp, #136]
    str x1, [sp, #144]
.Lurem_fused3_BB15:
    ldr x9, [sp, #136]
    ldr x10, [sp, #144]
    udiv x9, x9, x10
    str x9, [sp, #152]
    ldr x9, [sp, #152]
    movz x10, #10
    mul x9, x9, x10
    str x9, [sp, #160]
    ldr x9, [sp, #152]
    ldr x10, [sp, #160]
    add x9, x9, x10
    str x9, [sp, #168]
    ldr x9, [sp, #152]
    ldr x10, [sp, #144]
    mul x9, x9, x10
    str x9, [sp, #176]
    ldr x9, [sp, #136]
    ldr x10, [sp, #176]
    sub x9, x9, x10
    str x9, [sp, #184]
    ldr x9, [sp, #168]
    ldr x10, [sp, #184]
    add x9, x9, x10
    str x9, [sp, #192]
    ldr x0, [sp, #192]
    b .Lurem_fused3_epilogue
.Lurem_fused3_epilogue:
    add sp, sp, #208
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @no_fusion_single_use
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 176 bytes
# ========================================================
    .text
.globl no_fusion_single_use
no_fusion_single_use:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #176
    str x0, [sp, #136]
    str x1, [sp, #144]
.Lno_fusion_single_use_BB25:
    ldr x9, [sp, #136]
    ldr x10, [sp, #144]
    sdiv x9, x9, x10
    str x9, [sp, #152]
    ldr x9, [sp, #136]
    ldr x10, [sp, #144]
    sdiv x11, x9, x10
    msub x9, x10, x11, x9
    str x9, [sp, #160]
    ldr x9, [sp, #152]
    ldr x10, [sp, #160]
    add x9, x9, x10
    str x9, [sp, #168]
    ldr x0, [sp, #168]
    b .Lno_fusion_single_use_epilogue
.Lno_fusion_single_use_epilogue:
    add sp, sp, #176
    ldp x29, x30, [sp], #16
    ret


