# ========================================================
# Module: branchprop_demo
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @use_in_taken
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl use_in_taken
use_in_taken:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
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
    movz x0, #7
    b .Luse_in_taken_epilogue
.Luse_in_taken_BB5:
    mov x0, xzr
    b .Luse_in_taken_epilogue
.Luse_in_taken_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @use_in_else
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl use_in_else
use_in_else:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
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
    movz x0, #99
    b .Luse_in_else_epilogue
.Luse_in_else_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @use_both_after
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 144 bytes
# ========================================================
    .text
.globl use_both_after
use_both_after:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #144
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
    b .Luse_both_after_BB33
.Luse_both_after_BB34:
    b .Luse_both_after_BB34
.Luse_both_after_epilogue:
    add sp, sp, #144
    ldp x29, x30, [sp], #16
    ret


