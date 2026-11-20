# ========================================================
# Module: traildup
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @dup_test
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 192 bytes
# ========================================================
    .text
.globl dup_test
dup_test:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #192
    str x0, [sp, #136]
    str x1, [sp, #144]
.Ldup_test_BB4:
    ldr x9, [sp, #136]
    movz x10, #5
    cmp x9, x10
    cset w9, gt
    str x9, [sp, #152]
    ldr x9, [sp, #152]
    cbz x9, .Ldup_test_cse_9
    b .Ldup_test_BB5
.Ldup_test_cse_9:
    b .Ldup_test_BB6
.Ldup_test_BB5:
    ldr x9, [sp, #136]
    movz x10, #1
    lsl x9, x9, x10
    str x9, [sp, #160]
    ldr x0, [sp, #160]
    b .Ldup_test_epilogue
.Ldup_test_BB6:
    mov x9, xzr
    ldr x10, [sp, #144]
    sub x9, x9, x10
    str x9, [sp, #176]
    ldr x0, [sp, #176]
    b .Ldup_test_epilogue
.Ldup_test_epilogue:
    add sp, sp, #192
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
.Lmain_BB17:
    b .Lmain_BB30
.Lmain_BB30:
    movz x0, #14
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #144
    ldp x29, x30, [sp], #16
    ret


