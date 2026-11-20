# ========================================================
# Module: module_inline
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ ]
# Stack Frame: 192 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #192
.Lmain_BB2:
    b .Lmain_BB147
.Lmain_BB147:
    movz x0, #5
    bl neg_hint
    str x0, [sp, #136]
    bl const42
    str x0, [sp, #144]
    movz x0, #7
    bl param_const
    str x0, [sp, #152]
    b .Lmain_BB170
.Lmain_BB170:
    movz x0, #3
    bl rec
    str x0, [sp, #160]
    ldr x9, [sp, #160]
    movz x10, #249
    add x9, x9, x10
    str x9, [sp, #168]
    ldr x9, [sp, #168]
    str x9, [sp, #176]
    ldr x0, [sp, #176]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #192
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @tiny
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl tiny
tiny:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
    str x0, [sp, #136]
.Ltiny_BB29:
    ldr x9, [sp, #136]
    movz x10, #10
    add x9, x9, x10
    str x9, [sp, #144]
    ldr x0, [sp, #144]
    b .Ltiny_epilogue
.Ltiny_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @tiny_hint
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl tiny_hint
tiny_hint:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
    str x0, [sp, #136]
.Ltiny_hint_BB35:
    ldr x9, [sp, #136]
    movz x10, #20
    add x9, x9, x10
    str x9, [sp, #144]
    ldr x0, [sp, #144]
    b .Ltiny_hint_epilogue
.Ltiny_hint_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @always3
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 144 bytes
# ========================================================
    .text
.globl always3
always3:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #144
    str x0, [sp, #136]
.Lalways3_BB41:
    b .Lalways3_BB54
.Lalways3_BB54:
    movz x0, #99
    b .Lalways3_epilogue
.Lalways3_epilogue:
    add sp, sp, #144
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @neg_hint
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 144 bytes
# ========================================================
    .text
.globl neg_hint
neg_hint:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #144
    str x0, [sp, #136]
.Lneg_hint_BB72:
    movz x0, #35
    b .Lneg_hint_epilogue
.Lneg_hint_epilogue:
    add sp, sp, #144
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @const42
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 144 bytes
# ========================================================
    .text
.globl const42
const42:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #144
.Lconst42_BB77:
    movz x0, #42
    b .Lconst42_epilogue
.Lconst42_epilogue:
    add sp, sp, #144
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @param_const
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 144 bytes
# ========================================================
    .text
.globl param_const
param_const:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #144
    str x0, [sp, #136]
.Lparam_const_BB82:
    movz x0, #8
    b .Lparam_const_epilogue
.Lparam_const_epilogue:
    add sp, sp, #144
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @multi_ret
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl multi_ret
multi_ret:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
    str x0, [sp, #136]
.Lmulti_ret_BB88:
    ldr x9, [sp, #136]
    mov x10, xzr
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    cbz x9, .Lmulti_ret_cse_92
    b .Lmulti_ret_BB89
.Lmulti_ret_cse_92:
    b .Lmulti_ret_BB90
.Lmulti_ret_BB89:
    movz x0, #3
    b .Lmulti_ret_epilogue
.Lmulti_ret_BB90:
    movz x0, #4
    b .Lmulti_ret_epilogue
.Lmulti_ret_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @switch_ret
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl switch_ret
switch_ret:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
    str x0, [sp, #136]
.Lswitch_ret_BB98:
    ldr x9, [sp, #136]
    movz x10, #1
    cmp x9, x10
    b.eq .Lswitch_ret_sw_102_0
    movz x10, #2
    cmp x9, x10
    b.eq .Lswitch_ret_sw_102_1
    b .Lswitch_ret_swd_102
.Lswitch_ret_sw_102_0:
    b .Lswitch_ret_BB99
.Lswitch_ret_sw_102_1:
    b .Lswitch_ret_BB100
.Lswitch_ret_swd_102:
    b .Lswitch_ret_BB101
.Lswitch_ret_BB99:
    movz x0, #11
    b .Lswitch_ret_epilogue
.Lswitch_ret_BB100:
    movz x0, #22
    b .Lswitch_ret_epilogue
.Lswitch_ret_BB101:
    movz x0, #33
    b .Lswitch_ret_epilogue
.Lswitch_ret_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @rec
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ ]
# Stack Frame: 176 bytes
# ========================================================
    .text
.globl rec
rec:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #176
    str x0, [sp, #136]
.Lrec_BB111:
    ldr x9, [sp, #136]
    mov x10, xzr
    cmp x9, x10
    cset w9, le
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    cbz x9, .Lrec_cse_115
    b .Lrec_BB113
.Lrec_cse_115:
    b .Lrec_BB112
.Lrec_BB112:
    ldr x9, [sp, #136]
    movz x10, #1
    sub x9, x9, x10
    str x9, [sp, #152]
    ldr x0, [sp, #152]
    bl rec
    str x0, [sp, #160]
    ldr x0, [sp, #160]
    b .Lrec_epilogue
.Lrec_BB113:
    mov x0, xzr
    b .Lrec_epilogue
.Lrec_epilogue:
    add sp, sp, #176
    ldp x29, x30, [sp], #16
    ret


