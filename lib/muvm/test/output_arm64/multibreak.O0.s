# ========================================================
# Module: multibreak
# Target: AArch64 / AAPCS64
# ========================================================

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
.Lmain_BB2:
    movz x0, #10
    bl ticket
    str x0, [sp, #136]
    ldr x9, [sp, #136]
    str x9, [sp, #144]
    ldr x0, [sp, #144]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @ticket
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 224 bytes
# ========================================================
    .text
.globl ticket
ticket:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #224
    str x0, [sp, #136]
.Lticket_BB9:
    b .Lticket_BB10
.Lticket_BB10:
    ldr x9, [sp, #136]
    movz x10, #1000
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    cbz x9, .Lticket_cse_19
    b .Lticket_BB11
.Lticket_cse_19:
    mov x9, xzr
    str x9, [sp, #200]
    b .Lticket_BB15
.Lticket_BB11:
    mov x9, xzr
    str x9, [sp, #152]
    mov x9, xzr
    str x9, [sp, #160]
    b .Lticket_BB12
.Lticket_BB12:
    ldr x9, [sp, #152]
    ldr x10, [sp, #136]
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #168]
    ldr x9, [sp, #168]
    cbz x9, .Lticket_cse_25
    b .Lticket_BB13
.Lticket_cse_25:
    ldr x9, [sp, #160]
    str x9, [sp, #200]
    b .Lticket_BB15
.Lticket_BB13:
    ldr x9, [sp, #160]
    movz x10, #2
    add x9, x9, x10
    str x9, [sp, #176]
    ldr x9, [sp, #152]
    movz x10, #3
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #184]
    ldr x9, [sp, #184]
    cbz x9, .Lticket_cse_30
    ldr x9, [sp, #160]
    str x9, [sp, #200]
    b .Lticket_BB15
.Lticket_cse_30:
    b .Lticket_BB14
.Lticket_BB14:
    ldr x9, [sp, #152]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #192]
    ldr x9, [sp, #192]
    str x9, [sp, #152]
    ldr x9, [sp, #176]
    str x9, [sp, #160]
    b .Lticket_BB12
.Lticket_BB15:
    ldr x9, [sp, #200]
    movz x10, #42
    add x9, x9, x10
    str x9, [sp, #208]
    ldr x0, [sp, #208]
    b .Lticket_epilogue
.Lticket_epilogue:
    add sp, sp, #224
    ldp x29, x30, [sp], #16
    ret


