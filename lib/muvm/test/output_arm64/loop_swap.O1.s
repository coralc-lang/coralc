# ========================================================
# Module: nestflag
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @nest
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 272 bytes
# ========================================================
    .text
.globl nest
nest:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #272
    str x0, [sp, #136]
.Lnest_BB3:
    mov x9, xzr
    str x9, [sp, #144]
    mov x9, xzr
    str x9, [sp, #152]
    mov x9, xzr
    str x9, [sp, #160]
    b .Lnest_BB4
.Lnest_BB4:
    ldr x9, [sp, #144]
    movz x10, #3
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #168]
    ldr x9, [sp, #168]
    cbz x9, .Lnest_cse_21
    mov x9, xzr
    str x9, [sp, #176]
    mov x9, xzr
    str x9, [sp, #184]
    b .Lnest_BB6
.Lnest_cse_21:
    b .Lnest_BB13
.Lnest_BB6:
    b .Lnest_BB7
.Lnest_BB7:
    ldr x9, [sp, #136]
    movz x10, #7
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #192]
    ldr x9, [sp, #192]
    cbz x9, .Lnest_cse_28
    b .Lnest_BB8
.Lnest_cse_28:
    b .Lnest_BB9
.Lnest_BB8:
    ldr x9, [sp, #184]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #200]
    ldr x9, [sp, #200]
    str x9, [sp, #216]
    b .Lnest_BB10
.Lnest_BB9:
    ldr x9, [sp, #184]
    movz x10, #2
    add x9, x9, x10
    str x9, [sp, #208]
    ldr x9, [sp, #208]
    str x9, [sp, #216]
    b .Lnest_BB10
.Lnest_BB10:
    b .Lnest_BB11
.Lnest_BB11:
    ldr x9, [sp, #176]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #224]
    ldr x9, [sp, #224]
    movz x10, #4
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #232]
    ldr x9, [sp, #232]
    cbz x9, .Lnest_cse_40
    ldr x9, [sp, #224]
    str x9, [sp, #176]
    ldr x9, [sp, #216]
    str x9, [sp, #184]
    b .Lnest_BB6
.Lnest_cse_40:
    b .Lnest_BB12
.Lnest_BB12:
    ldr x9, [sp, #144]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #240]
    ldr x9, [sp, #240]
    str x9, [sp, #144]
    ldr x9, [sp, #176]
    str x9, [sp, #152]
    ldr x9, [sp, #184]
    str x9, [sp, #160]
    b .Lnest_BB4
.Lnest_BB13:
    ldr x9, [sp, #152]
    movz x10, #10
    mul x9, x9, x10
    str x9, [sp, #248]
    ldr x9, [sp, #248]
    ldr x10, [sp, #144]
    add x9, x9, x10
    str x9, [sp, #256]
    ldr x9, [sp, #256]
    ldr x10, [sp, #160]
    add x9, x9, x10
    str x9, [sp, #264]
    ldr x0, [sp, #264]
    b .Lnest_epilogue
.Lnest_epilogue:
    add sp, sp, #272
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
.Lmain_BB49:
    movz x0, #7
    bl nest
    str x0, [sp, #136]
    ldr x9, [sp, #136]
    str x9, [sp, #144]
    ldr x0, [sp, #144]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret


