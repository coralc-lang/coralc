# ========================================================
# Module: bigmodule
# Target: AArch64 / AAPCS64
# ========================================================

# ---- Global Variables ----
    .data
    .align 8
.globl g
g:
    .quad 3

# ========================================================
# Function: @square
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl square
square:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
    str x0, [sp, #136]
.Lsquare_BB5:
    ldr x9, [sp, #136]
    ldr x10, [sp, #136]
    mul x9, x9, x10
    str x9, [sp, #144]
    ldr x0, [sp, #144]
    b .Lsquare_epilogue
.Lsquare_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @cube
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl cube
cube:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
    str x0, [sp, #136]
.Lcube_BB10:
    ldr x9, [sp, #136]
    ldr x10, [sp, #136]
    mul x9, x9, x10
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    ldr x10, [sp, #136]
    mul x9, x9, x10
    str x9, [sp, #152]
    ldr x0, [sp, #152]
    b .Lcube_epilogue
.Lcube_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @sum_to
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 192 bytes
# ========================================================
    .text
.globl sum_to
sum_to:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #192
    str x0, [sp, #136]
.Lsum_to_BB16:
    mov x9, xzr
    str x9, [sp, #144]
    mov x9, xzr
    str x9, [sp, #152]
    b .Lsum_to_BB17
.Lsum_to_BB17:
    ldr x9, [sp, #144]
    ldr x10, [sp, #136]
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #160]
    ldr x9, [sp, #160]
    cbz x9, .Lsum_to_cse_25
    b .Lsum_to_BB18
.Lsum_to_cse_25:
    b .Lsum_to_BB19
.Lsum_to_BB18:
    ldr x9, [sp, #152]
    ldr x10, [sp, #144]
    add x9, x9, x10
    str x9, [sp, #168]
    ldr x9, [sp, #144]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #176]
    ldr x9, [sp, #176]
    str x9, [sp, #144]
    ldr x9, [sp, #168]
    str x9, [sp, #152]
    b .Lsum_to_BB17
.Lsum_to_BB19:
    ldr x0, [sp, #152]
    b .Lsum_to_epilogue
.Lsum_to_epilogue:
    add sp, sp, #192
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @collatz
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 224 bytes
# ========================================================
    .text
.globl collatz
collatz:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #224
    str x0, [sp, #136]
.Lcollatz_BB33:
    ldr x9, [sp, #136]
    str x9, [sp, #144]
    mov x9, xzr
    str x9, [sp, #152]
    b .Lcollatz_BB34
.Lcollatz_BB34:
    ldr x9, [sp, #144]
    movz x10, #1
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #160]
    ldr x9, [sp, #160]
    cbz x9, .Lcollatz_cse_41
    b .Lcollatz_BB36
.Lcollatz_cse_41:
    b .Lcollatz_BB35
.Lcollatz_BB35:
    ldr x9, [sp, #144]
    movz x10, #1
    and x9, x9, x10
    str x9, [sp, #168]
    ldr x9, [sp, #144]
    movz x10, #1
    lsr x9, x9, x10
    str x9, [sp, #176]
    ldr x9, [sp, #144]
    movz x10, #3
    mul x9, x9, x10
    str x9, [sp, #184]
    ldr x9, [sp, #184]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #192]
    ldr x9, [sp, #168]
    movz x10, #1
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #200]
    ldr x9, [sp, #200]
    ldr x10, [sp, #192]
    ldr x11, [sp, #176]
    cmp x9, xzr
    csel x10, x10, x11, ne
    str x10, [sp, #208]
    ldr x9, [sp, #152]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #216]
    ldr x9, [sp, #208]
    str x9, [sp, #144]
    ldr x9, [sp, #216]
    str x9, [sp, #152]
    b .Lcollatz_BB34
.Lcollatz_BB36:
    ldr x0, [sp, #152]
    b .Lcollatz_epilogue
.Lcollatz_epilogue:
    add sp, sp, #224
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @fib
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 192 bytes
# ========================================================
    .text
.globl fib
fib:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #192
    str x0, [sp, #136]
.Lfib_BB53:
    mov x9, xzr
    str x9, [sp, #144]
    mov x9, xzr
    str x9, [sp, #152]
    movz x9, #1
    str x9, [sp, #160]
    b .Lfib_BB54
.Lfib_BB54:
    ldr x9, [sp, #144]
    ldr x10, [sp, #136]
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #168]
    ldr x9, [sp, #168]
    cbz x9, .Lfib_cse_62
    b .Lfib_BB55
.Lfib_cse_62:
    b .Lfib_BB56
.Lfib_BB55:
    ldr x9, [sp, #152]
    ldr x10, [sp, #160]
    add x9, x9, x10
    str x9, [sp, #176]
    ldr x9, [sp, #144]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #184]
    ldr x9, [sp, #160]
    str x9, [sp, #64]
    ldr x9, [sp, #184]
    str x9, [sp, #144]
    ldr x9, [sp, #64]
    str x9, [sp, #152]
    ldr x9, [sp, #176]
    str x9, [sp, #160]
    b .Lfib_BB54
.Lfib_BB56:
    ldr x0, [sp, #152]
    b .Lfib_epilogue
.Lfib_epilogue:
    add sp, sp, #192
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @sum_squares_range
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 208 bytes
# ========================================================
    .text
.globl sum_squares_range
sum_squares_range:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #208
    str x0, [sp, #136]
    str x1, [sp, #144]
.Lsum_squares_range_BB70:
    ldr x9, [sp, #136]
    str x9, [sp, #152]
    mov x9, xzr
    str x9, [sp, #160]
    b .Lsum_squares_range_BB71
.Lsum_squares_range_BB71:
    ldr x9, [sp, #152]
    ldr x10, [sp, #144]
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #168]
    ldr x9, [sp, #168]
    cbz x9, .Lsum_squares_range_cse_78
    b .Lsum_squares_range_BB72
.Lsum_squares_range_cse_78:
    b .Lsum_squares_range_BB73
.Lsum_squares_range_BB72:
    ldr x9, [sp, #152]
    ldr x10, [sp, #152]
    mul x9, x9, x10
    str x9, [sp, #176]
    ldr x9, [sp, #160]
    ldr x10, [sp, #176]
    add x9, x9, x10
    str x9, [sp, #184]
    ldr x9, [sp, #152]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #192]
    ldr x9, [sp, #192]
    str x9, [sp, #152]
    ldr x9, [sp, #184]
    str x9, [sp, #160]
    b .Lsum_squares_range_BB71
.Lsum_squares_range_BB73:
    ldr x0, [sp, #160]
    b .Lsum_squares_range_epilogue
.Lsum_squares_range_epilogue:
    add sp, sp, #208
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @fact
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 192 bytes
# ========================================================
    .text
.globl fact
fact:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #192
    str x0, [sp, #136]
.Lfact_BB86:
    movz x9, #1
    str x9, [sp, #144]
    movz x9, #1
    str x9, [sp, #152]
    b .Lfact_BB87
.Lfact_BB87:
    ldr x9, [sp, #144]
    ldr x10, [sp, #136]
    cmp x9, x10
    cset w9, le
    str x9, [sp, #160]
    ldr x9, [sp, #160]
    cbz x9, .Lfact_cse_94
    b .Lfact_BB88
.Lfact_cse_94:
    b .Lfact_BB89
.Lfact_BB88:
    ldr x9, [sp, #152]
    ldr x10, [sp, #144]
    mul x9, x9, x10
    str x9, [sp, #168]
    ldr x9, [sp, #144]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #176]
    ldr x9, [sp, #176]
    str x9, [sp, #144]
    ldr x9, [sp, #168]
    str x9, [sp, #152]
    b .Lfact_BB87
.Lfact_BB89:
    ldr x0, [sp, #152]
    b .Lfact_epilogue
.Lfact_epilogue:
    add sp, sp, #192
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @gcd
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 192 bytes
# ========================================================
    .text
.globl gcd
gcd:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #192
    str x0, [sp, #136]
    str x1, [sp, #144]
.Lgcd_BB102:
    ldr x9, [sp, #136]
    str x9, [sp, #152]
    ldr x9, [sp, #144]
    str x9, [sp, #160]
    b .Lgcd_BB103
.Lgcd_BB103:
    ldr x9, [sp, #160]
    mov x10, xzr
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #168]
    ldr x9, [sp, #168]
    cbz x9, .Lgcd_cse_110
    b .Lgcd_BB105
.Lgcd_cse_110:
    b .Lgcd_BB104
.Lgcd_BB104:
    ldr x9, [sp, #152]
    ldr x10, [sp, #160]
    sdiv x11, x9, x10
    msub x9, x10, x11, x9
    str x9, [sp, #176]
    ldr x9, [sp, #160]
    str x9, [sp, #64]
    ldr x9, [sp, #64]
    str x9, [sp, #152]
    ldr x9, [sp, #176]
    str x9, [sp, #160]
    b .Lgcd_BB103
.Lgcd_BB105:
    ldr x0, [sp, #152]
    b .Lgcd_epilogue
.Lgcd_epilogue:
    add sp, sp, #192
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @count_bits
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 192 bytes
# ========================================================
    .text
.globl count_bits
count_bits:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #192
    str x0, [sp, #136]
.Lcount_bits_BB116:
    ldr x9, [sp, #136]
    str x9, [sp, #144]
    mov x9, xzr
    str x9, [sp, #152]
    b .Lcount_bits_BB117
.Lcount_bits_BB117:
    ldr x9, [sp, #144]
    mov x10, xzr
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #160]
    ldr x9, [sp, #160]
    cbz x9, .Lcount_bits_cse_124
    b .Lcount_bits_BB119
.Lcount_bits_cse_124:
    b .Lcount_bits_BB118
.Lcount_bits_BB118:
    ldr x9, [sp, #144]
    movz x10, #1
    and x9, x9, x10
    str x9, [sp, #168]
    ldr x9, [sp, #152]
    ldr x10, [sp, #168]
    add x9, x9, x10
    str x9, [sp, #176]
    ldr x9, [sp, #144]
    movz x10, #1
    lsr x9, x9, x10
    str x9, [sp, #184]
    ldr x9, [sp, #184]
    str x9, [sp, #144]
    ldr x9, [sp, #176]
    str x9, [sp, #152]
    b .Lcount_bits_BB117
.Lcount_bits_BB119:
    ldr x0, [sp, #152]
    b .Lcount_bits_epilogue
.Lcount_bits_epilogue:
    add sp, sp, #192
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @poly
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 224 bytes
# ========================================================
    .text
.globl poly
poly:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #224
    str x0, [sp, #136]
.Lpoly_BB132:
    ldr x9, [sp, #136]
    ldr x10, [sp, #136]
    mul x9, x9, x10
    str x9, [sp, #144]
    movz x9, #2
    ldr x10, [sp, #136]
    mul x9, x9, x10
    str x9, [sp, #152]
    ldr x9, [sp, #144]
    ldr x10, [sp, #152]
    add x9, x9, x10
    str x9, [sp, #160]
    ldr x9, [sp, #160]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #168]
    ldr x9, [sp, #136]
    ldr x10, [sp, #136]
    mul x9, x9, x10
    str x9, [sp, #176]
    movz x9, #2
    ldr x10, [sp, #136]
    mul x9, x9, x10
    str x9, [sp, #184]
    ldr x9, [sp, #176]
    ldr x10, [sp, #184]
    add x9, x9, x10
    str x9, [sp, #192]
    ldr x9, [sp, #192]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #200]
    ldr x9, [sp, #168]
    ldr x10, [sp, #200]
    add x9, x9, x10
    str x9, [sp, #208]
    ldr x0, [sp, #208]
    b .Lpoly_epilogue
.Lpoly_epilogue:
    add sp, sp, #224
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @invar_loop
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 208 bytes
# ========================================================
    .text
.globl invar_loop
invar_loop:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #208
    str x0, [sp, #136]
    str x1, [sp, #144]
.Linvar_loop_BB147:
    mov x9, xzr
    str x9, [sp, #152]
    mov x9, xzr
    str x9, [sp, #160]
    b .Linvar_loop_BB148
.Linvar_loop_BB148:
    ldr x9, [sp, #152]
    ldr x10, [sp, #136]
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #168]
    ldr x9, [sp, #168]
    cbz x9, .Linvar_loop_cse_155
    b .Linvar_loop_BB149
.Linvar_loop_cse_155:
    b .Linvar_loop_BB150
.Linvar_loop_BB149:
    ldr x9, [sp, #144]
    movz x10, #7
    mul x9, x9, x10
    str x9, [sp, #176]
    ldr x9, [sp, #160]
    ldr x10, [sp, #176]
    add x9, x9, x10
    str x9, [sp, #184]
    ldr x9, [sp, #152]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #192]
    ldr x9, [sp, #192]
    str x9, [sp, #152]
    ldr x9, [sp, #184]
    str x9, [sp, #160]
    b .Linvar_loop_BB148
.Linvar_loop_BB150:
    ldr x0, [sp, #160]
    b .Linvar_loop_epilogue
.Linvar_loop_epilogue:
    add sp, sp, #208
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @big_switch
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 304 bytes
# ========================================================
    .text
.globl big_switch
big_switch:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #304
    str x0, [sp, #136]
.Lbig_switch_BB164:
    ldr x9, [sp, #136]
    mov x10, xzr
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    cbz x9, .Lbig_switch_cse_186
    b .Lbig_switch_BB174
.Lbig_switch_cse_186:
    b .Lbig_switch_BB165
.Lbig_switch_BB165:
    ldr x9, [sp, #136]
    movz x10, #1
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #152]
    ldr x9, [sp, #152]
    cbz x9, .Lbig_switch_cse_188
    b .Lbig_switch_BB175
.Lbig_switch_cse_188:
    b .Lbig_switch_BB166
.Lbig_switch_BB166:
    ldr x9, [sp, #136]
    movz x10, #2
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #160]
    ldr x9, [sp, #160]
    cbz x9, .Lbig_switch_cse_190
    b .Lbig_switch_BB176
.Lbig_switch_cse_190:
    b .Lbig_switch_BB167
.Lbig_switch_BB167:
    ldr x9, [sp, #136]
    movz x10, #3
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #168]
    ldr x9, [sp, #168]
    cbz x9, .Lbig_switch_cse_192
    b .Lbig_switch_BB177
.Lbig_switch_cse_192:
    b .Lbig_switch_BB168
.Lbig_switch_BB168:
    ldr x9, [sp, #136]
    movz x10, #4
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #176]
    ldr x9, [sp, #176]
    cbz x9, .Lbig_switch_cse_195
    b .Lbig_switch_BB178
.Lbig_switch_cse_195:
    b .Lbig_switch_BB169
.Lbig_switch_BB169:
    ldr x9, [sp, #136]
    movz x10, #5
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #184]
    ldr x9, [sp, #184]
    cbz x9, .Lbig_switch_cse_198
    b .Lbig_switch_BB179
.Lbig_switch_cse_198:
    b .Lbig_switch_BB170
.Lbig_switch_BB170:
    ldr x9, [sp, #136]
    movz x10, #6
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #192]
    ldr x9, [sp, #192]
    cbz x9, .Lbig_switch_cse_201
    b .Lbig_switch_BB180
.Lbig_switch_cse_201:
    b .Lbig_switch_BB171
.Lbig_switch_BB171:
    ldr x9, [sp, #136]
    movz x10, #7
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #200]
    ldr x9, [sp, #200]
    cbz x9, .Lbig_switch_cse_203
    b .Lbig_switch_BB181
.Lbig_switch_cse_203:
    b .Lbig_switch_BB172
.Lbig_switch_BB172:
    ldr x9, [sp, #136]
    movz x10, #8
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #208]
    ldr x9, [sp, #208]
    cbz x9, .Lbig_switch_cse_206
    b .Lbig_switch_BB182
.Lbig_switch_cse_206:
    b .Lbig_switch_BB173
.Lbig_switch_BB173:
    ldr x9, [sp, #136]
    movz x10, #9
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #216]
    ldr x9, [sp, #216]
    cbz x9, .Lbig_switch_cse_209
    b .Lbig_switch_BB183
.Lbig_switch_cse_209:
    b .Lbig_switch_BB184
.Lbig_switch_BB174:
    movz x0, #1
    b .Lbig_switch_epilogue
.Lbig_switch_BB175:
    movz x0, #2
    b .Lbig_switch_epilogue
.Lbig_switch_BB176:
    movz x0, #4
    b .Lbig_switch_epilogue
.Lbig_switch_BB177:
    movz x0, #8
    b .Lbig_switch_epilogue
.Lbig_switch_BB178:
    movz x0, #16
    b .Lbig_switch_epilogue
.Lbig_switch_BB179:
    movz x0, #32
    b .Lbig_switch_epilogue
.Lbig_switch_BB180:
    movz x0, #64
    b .Lbig_switch_epilogue
.Lbig_switch_BB181:
    movz x0, #128
    b .Lbig_switch_epilogue
.Lbig_switch_BB182:
    movz x0, #256
    b .Lbig_switch_epilogue
.Lbig_switch_BB183:
    movz x0, #512
    b .Lbig_switch_epilogue
.Lbig_switch_BB184:
    movz x0, #1024
    b .Lbig_switch_epilogue
.Lbig_switch_epilogue:
    add sp, sp, #304
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @const_chain
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 192 bytes
# ========================================================
    .text
.globl const_chain
const_chain:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #192
.Lconst_chain_BB229:
    movz x9, #1
    movz x10, #2
    add x9, x9, x10
    str x9, [sp, #136]
    ldr x9, [sp, #136]
    movz x10, #3
    mul x9, x9, x10
    str x9, [sp, #144]
    movz x9, #4
    movz x10, #5
    mul x9, x9, x10
    str x9, [sp, #152]
    ldr x9, [sp, #144]
    ldr x10, [sp, #152]
    add x9, x9, x10
    str x9, [sp, #160]
    ldr x9, [sp, #160]
    movz x10, #6
    add x9, x9, x10
    str x9, [sp, #168]
    ldr x9, [sp, #168]
    movz x10, #7
    mul x9, x9, x10
    str x9, [sp, #176]
    ldr x0, [sp, #176]
    b .Lconst_chain_epilogue
.Lconst_chain_epilogue:
    add sp, sp, #192
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @redundant
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 176 bytes
# ========================================================
    .text
.globl redundant
redundant:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #176
    str x0, [sp, #136]
.Lredundant_BB239:
    ldr x9, [sp, #136]
    ldr x10, [sp, #136]
    eor x9, x9, x10
    str x9, [sp, #144]
    ldr x9, [sp, #144]
    movz x10, #1
    cmp x9, x10
    cset w9, eq
    str x9, [sp, #152]
    ldr x9, [sp, #152]
    movz x10, #999
    movz x11, #42
    cmp x9, xzr
    csel x10, x10, x11, ne
    str x10, [sp, #160]
    ldr x0, [sp, #160]
    b .Lredundant_epilogue
.Lredundant_epilogue:
    add sp, sp, #176
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @xor_self
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl xor_self
xor_self:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
    str x0, [sp, #136]
.Lxor_self_BB248:
    ldr x9, [sp, #136]
    ldr x10, [sp, #136]
    eor x9, x9, x10
    str x9, [sp, #144]
    ldr x0, [sp, #144]
    b .Lxor_self_epilogue
.Lxor_self_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @select_real
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 176 bytes
# ========================================================
    .text
.globl select_real
select_real:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #176
    str x0, [sp, #136]
    str x1, [sp, #144]
.Lselect_real_BB254:
    ldr x9, [sp, #136]
    ldr x10, [sp, #144]
    cmp x9, x10
    cset w9, gt
    str x9, [sp, #152]
    ldr x9, [sp, #152]
    ldr x10, [sp, #136]
    ldr x11, [sp, #144]
    cmp x9, xzr
    csel x10, x10, x11, ne
    str x10, [sp, #160]
    ldr x0, [sp, #160]
    b .Lselect_real_epilogue
.Lselect_real_epilogue:
    add sp, sp, #176
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @phi_const_combo
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 176 bytes
# ========================================================
    .text
.globl phi_const_combo
phi_const_combo:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #176
    str x0, [sp, #136]
    str x1, [sp, #144]
.Lphi_const_combo_BB261:
    ldr x9, [sp, #136]
    ldr x10, [sp, #144]
    cmp x9, x10
    cset w9, gt
    str x9, [sp, #152]
    ldr x9, [sp, #152]
    cbz x9, .Lphi_const_combo_cse_266
    b .Lphi_const_combo_BB262
.Lphi_const_combo_cse_266:
    b .Lphi_const_combo_BB263
.Lphi_const_combo_BB262:
    movz x9, #100
    str x9, [sp, #160]
    b .Lphi_const_combo_BB264
.Lphi_const_combo_BB263:
    movz x9, #200
    str x9, [sp, #160]
    b .Lphi_const_combo_BB264
.Lphi_const_combo_BB264:
    ldr x9, [sp, #160]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #168]
    ldr x0, [sp, #168]
    b .Lphi_const_combo_epilogue
.Lphi_const_combo_epilogue:
    add sp, sp, #176
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @same_pick
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 176 bytes
# ========================================================
    .text
.globl same_pick
same_pick:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #176
    mov w9, w0
    str x9, [sp, #136]
    str x1, [sp, #144]
    str x2, [sp, #152]
.Lsame_pick_BB278:
    ldr x9, [sp, #136]
    ldr x10, [sp, #144]
    ldr x11, [sp, #152]
    cmp x9, xzr
    csel x10, x10, x11, ne
    str x10, [sp, #160]
    ldr x0, [sp, #160]
    b .Lsame_pick_epilogue
.Lsame_pick_epilogue:
    add sp, sp, #176
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @select_same
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 160 bytes
# ========================================================
    .text
.globl select_same
select_same:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #160
    mov w9, w0
    str x9, [sp, #136]
    str x1, [sp, #144]
.Lselect_same_BB284:
    ldr x9, [sp, #136]
    ldr x10, [sp, #144]
    ldr x11, [sp, #144]
    cmp x9, xzr
    csel x10, x10, x11, ne
    str x10, [sp, #152]
    ldr x0, [sp, #152]
    b .Lselect_same_epilogue
.Lselect_same_epilogue:
    add sp, sp, #160
    ldp x29, x30, [sp], #16
    ret

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ ]
# Stack Frame: 448 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #448
.Lmain_BB288:
    adrp x9, g
    add x9, x9, :lo12:g
    ldr x10, [x9]
    str x10, [sp, #136]
    ldr x0, [sp, #136]
    bl square
    str x0, [sp, #144]
    ldr x0, [sp, #136]
    bl cube
    str x0, [sp, #152]
    movz x0, #8
    bl sum_to
    str x0, [sp, #160]
    movz x0, #10
    bl fib
    str x0, [sp, #168]
    movz x0, #1
    movz x1, #8
    bl sum_squares_range
    str x0, [sp, #176]
    movz x0, #5
    bl fact
    str x0, [sp, #184]
    movz x0, #1071
    movz x1, #462
    bl gcd
    str x0, [sp, #192]
    movz x0, #12345
    bl count_bits
    str x0, [sp, #200]
    movz x0, #3
    bl poly
    str x0, [sp, #208]
    movz x0, #4
    movz x1, #5
    bl invar_loop
    str x0, [sp, #216]
    movz x0, #7
    bl big_switch
    str x0, [sp, #224]
    bl const_chain
    str x0, [sp, #232]
    movz x0, #9
    bl redundant
    str x0, [sp, #240]
    movz x0, #123
    bl xor_self
    str x0, [sp, #248]
    movz x0, #10
    movz x1, #20
    bl select_real
    str x0, [sp, #256]
    movz x0, #1
    movz x1, #7
    movz x2, #9
    bl same_pick
    str x0, [sp, #264]
    mov x0, xzr
    movz x1, #99
    bl select_same
    str x0, [sp, #272]
    movz x0, #3
    movz x1, #5
    bl phi_const_combo
    str x0, [sp, #280]
    ldr x9, [sp, #144]
    ldr x10, [sp, #152]
    add x9, x9, x10
    str x9, [sp, #288]
    ldr x9, [sp, #288]
    ldr x10, [sp, #160]
    add x9, x9, x10
    str x9, [sp, #296]
    ldr x9, [sp, #296]
    ldr x10, [sp, #168]
    add x9, x9, x10
    str x9, [sp, #304]
    ldr x9, [sp, #304]
    ldr x10, [sp, #176]
    add x9, x9, x10
    str x9, [sp, #312]
    ldr x9, [sp, #312]
    ldr x10, [sp, #184]
    add x9, x9, x10
    str x9, [sp, #320]
    ldr x9, [sp, #320]
    ldr x10, [sp, #192]
    add x9, x9, x10
    str x9, [sp, #328]
    ldr x9, [sp, #328]
    ldr x10, [sp, #200]
    add x9, x9, x10
    str x9, [sp, #336]
    ldr x9, [sp, #336]
    ldr x10, [sp, #208]
    add x9, x9, x10
    str x9, [sp, #344]
    ldr x9, [sp, #344]
    ldr x10, [sp, #216]
    add x9, x9, x10
    str x9, [sp, #352]
    ldr x9, [sp, #352]
    ldr x10, [sp, #224]
    add x9, x9, x10
    str x9, [sp, #360]
    ldr x9, [sp, #360]
    ldr x10, [sp, #232]
    add x9, x9, x10
    str x9, [sp, #368]
    ldr x9, [sp, #368]
    ldr x10, [sp, #240]
    add x9, x9, x10
    str x9, [sp, #376]
    ldr x9, [sp, #376]
    ldr x10, [sp, #248]
    add x9, x9, x10
    str x9, [sp, #384]
    ldr x9, [sp, #384]
    ldr x10, [sp, #256]
    add x9, x9, x10
    str x9, [sp, #392]
    ldr x9, [sp, #392]
    ldr x10, [sp, #264]
    add x9, x9, x10
    str x9, [sp, #400]
    ldr x9, [sp, #400]
    ldr x10, [sp, #272]
    add x9, x9, x10
    str x9, [sp, #408]
    ldr x9, [sp, #408]
    ldr x10, [sp, #280]
    add x9, x9, x10
    str x9, [sp, #416]
    ldr x9, [sp, #416]
    movz x10, #255
    and x9, x9, x10
    str x9, [sp, #424]
    ldr x9, [sp, #424]
    str x9, [sp, #432]
    ldr x0, [sp, #432]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #448
    ldp x29, x30, [sp], #16
    ret


