# ========================================================
# Module: branchprop_demo
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @use_in_taken
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 192 bytes
# ========================================================
    .text
.globl use_in_taken
use_in_taken:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #192
    str x0, [sp, #136]
.Luse_in_taken_BB3:
    ldr x9, [sp, #136]
    movz x10, #42
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    cbz x9, .Luse_in_taken_cse_8
    b .Luse_in_taken_BB4
.Luse_in_taken_cse_8:
    b .Luse_in_taken_BB5
.Luse_in_taken_BB4:
    ldr x9, [sp, #136]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #152]
    ldr x9, [sp, #136]
    movz x10, #42
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #160]
    ldr x9, [sp, #160]
    movz x10, #7
    movz x11, #99
    cmp x9, xzr
    csel x10, x10, x11, ne
    str x10, [sp, #168]
    ldr x0, [sp, #168]
    b .Luse_in_taken_epilogue
.Luse_in_taken_BB5:
    mov x0, xzr
    b .Luse_in_taken_epilogue
.Luse_in_taken_epilogue:
    add sp, sp, #192
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @use_in_else
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 192 bytes
# ========================================================
    .text
.globl use_in_else
use_in_else:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #192
    str x0, [sp, #136]
.Luse_in_else_BB20:
    ldr x9, [sp, #136]
    movz x10, #42
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    cbz x9, .Luse_in_else_cse_24
    b .Luse_in_else_BB21
.Luse_in_else_cse_24:
    b .Luse_in_else_BB22
.Luse_in_else_BB21:
    movz x0, #1
    b .Luse_in_else_epilogue
.Luse_in_else_BB22:
    ldr x9, [sp, #136]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #160]
    ldr x9, [sp, #136]
    movz x10, #42
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #168]
    ldr x9, [sp, #168]
    movz x10, #7
    movz x11, #99
    cmp x9, xzr
    csel x10, x10, x11, ne
    str x10, [sp, #176]
    ldr x0, [sp, #176]
    b .Luse_in_else_epilogue
.Luse_in_else_epilogue:
    add sp, sp, #192
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @use_both_after
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl use_both_after
use_both_after:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
    str x0, [sp, #136]
.Luse_both_after_BB32:
    ldr x9, [sp, #136]
    movz x10, #42
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    cbz x9, .Luse_both_after_cse_36
    b .Luse_both_after_BB33
.Luse_both_after_cse_36:
    b .Luse_both_after_BB34
.Luse_both_after_BB33:
    ldr x9, [sp, #136]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #152]
    ldr x9, [sp, #144]
    cbz x9, .Luse_both_after_cse_38
    b .Luse_both_after_BB33
.Luse_both_after_cse_38:
    b .Luse_both_after_BB34
.Luse_both_after_BB34:
    ldr x9, [sp, #136]
    movz x10, #2
    add x9, x9, x10
    str x9, [sp, #160]
    ldr x9, [sp, #144]
    cbz x9, .Luse_both_after_cse_41
    b .Luse_both_after_BB33
.Luse_both_after_cse_41:
    b .Luse_both_after_BB34
.Luse_both_after_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret


