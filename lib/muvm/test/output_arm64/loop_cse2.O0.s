# ========================================================
# Module: loopcse_demo
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ ]
# Stack Frame: 176 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #176
.Lmain_BB2:
    add x9, sp, #152
    str x9, [sp, #144]
    ldr x0, [sp, #144]
    movz x1, #10
    bl sum_of_n
    str x0, [sp, #152]
    ldr x9, [sp, #152]
    str x9, [sp, #160]
    ldr x0, [sp, #160]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #176
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @sum_of_n
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 208 bytes
# ========================================================
    .text
.globl sum_of_n
sum_of_n:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #208
    str x0, [sp, #136]
    str x1, [sp, #144]
.Lsum_of_n_BB11:
    mov x9, xzr
    str x9, [sp, #152]
    mov x9, xzr
    str x9, [sp, #160]
    b .Lsum_of_n_BB12
.Lsum_of_n_BB12:
    ldr x9, [sp, #136]
    ldr x10, [sp, #152]
    add x9, x9, x10
    str x9, [sp, #168]
    ldr x9, [sp, #168]
    ldr x10, [x9]
    str x10, [sp, #176]
    ldr x9, [sp, #160]
    ldr x10, [sp, #176]
    add x9, x9, x10
    str x9, [sp, #184]
    ldr x9, [sp, #152]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #192]
    ldr x9, [sp, #192]
    ldr x10, [sp, #144]
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #200]
    ldr x9, [sp, #200]
    cbz x9, .Lsum_of_n_cse_24
    ldr x9, [sp, #192]
    str x9, [sp, #152]
    ldr x9, [sp, #184]
    str x9, [sp, #160]
    b .Lsum_of_n_BB12
.Lsum_of_n_cse_24:
    b .Lsum_of_n_BB13
.Lsum_of_n_BB13:
    ldr x0, [sp, #184]
    b .Lsum_of_n_epilogue
.Lsum_of_n_epilogue:
    add sp, sp, #208
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @sum_no_invariant
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 224 bytes
# ========================================================
    .text
.globl sum_no_invariant
sum_no_invariant:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #224
    str x0, [sp, #136]
    str x1, [sp, #144]
.Lsum_no_invariant_BB29:
    mov x9, xzr
    str x9, [sp, #152]
    mov x9, xzr
    str x9, [sp, #160]
    b .Lsum_no_invariant_BB30
.Lsum_no_invariant_BB30:
    ldr x9, [sp, #152]
    mov x10, xzr
    add x9, x9, x10
    str x9, [sp, #168]
    ldr x9, [sp, #136]
    ldr x10, [sp, #168]
    add x9, x9, x10
    str x9, [sp, #176]
    ldr x9, [sp, #176]
    ldr x10, [x9]
    str x10, [sp, #184]
    ldr x9, [sp, #160]
    ldr x10, [sp, #184]
    add x9, x9, x10
    str x9, [sp, #192]
    ldr x9, [sp, #152]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #200]
    ldr x9, [sp, #200]
    ldr x10, [sp, #144]
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #208]
    ldr x9, [sp, #208]
    cbz x9, .Lsum_no_invariant_cse_41
    ldr x9, [sp, #200]
    str x9, [sp, #152]
    ldr x9, [sp, #192]
    str x9, [sp, #160]
    b .Lsum_no_invariant_BB30
.Lsum_no_invariant_cse_41:
    b .Lsum_no_invariant_BB31
.Lsum_no_invariant_BB31:
    ldr x0, [sp, #192]
    b .Lsum_no_invariant_epilogue
.Lsum_no_invariant_epilogue:
    add sp, sp, #224
    ldp x29, x30, [sp], #16
    ret


