# ========================================================
# Module: gvn_scope
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @same_text
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 176 bytes
# ========================================================
    .text
.globl same_text
same_text:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #176
    str x0, [sp, #136]
    mov w9, w1
    str x9, [sp, #144]
.Lsame_text_BB4:
    ldr x9, [sp, #136]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #152]
    ldr x9, [sp, #144]
    cbz x9, .Lsame_text_cse_9
    b .Lsame_text_BB5
.Lsame_text_cse_9:
    b .Lsame_text_BB6
.Lsame_text_BB5:
    ldr x0, [sp, #152]
    b .Lsame_text_epilogue
.Lsame_text_BB6:
    ldr x0, [sp, #152]
    b .Lsame_text_epilogue
.Lsame_text_epilogue:
    add sp, sp, #176
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @sibling_blocks
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 192 bytes
# ========================================================
    .text
.globl sibling_blocks
sibling_blocks:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #192
    str x0, [sp, #136]
    mov w9, w1
    str x9, [sp, #144]
.Lsibling_blocks_BB17:
    ldr x9, [sp, #144]
    cbz x9, .Lsibling_blocks_cse_20
    b .Lsibling_blocks_BB18
.Lsibling_blocks_cse_20:
    b .Lsibling_blocks_BB19
.Lsibling_blocks_BB18:
    ldr x9, [sp, #136]
    movz x10, #7
    add x9, x9, x10
    str x9, [sp, #152]
    ldr x0, [sp, #152]
    b .Lsibling_blocks_epilogue
.Lsibling_blocks_BB19:
    ldr x9, [sp, #136]
    movz x10, #7
    add x9, x9, x10
    str x9, [sp, #168]
    ldr x9, [sp, #136]
    movz x10, #8
    add x9, x9, x10
    str x9, [sp, #176]
    ldr x9, [sp, #168]
    ldr x10, [sp, #176]
    add x9, x9, x10
    str x9, [sp, #184]
    ldr x0, [sp, #184]
    b .Lsibling_blocks_epilogue
.Lsibling_blocks_epilogue:
    add sp, sp, #192
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @block_local
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl block_local
block_local:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
    str x0, [sp, #136]
.Lblock_local_BB32:
    ldr x9, [sp, #136]
    movz x10, #3
    add x9, x9, x10
    str x9, [sp, #144]
    ldr x0, [sp, #144]
    b .Lblock_local_epilogue
.Lblock_local_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret


