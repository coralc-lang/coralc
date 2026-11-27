# ========================================================
# Module: aa_arg_ptr
# Target OS: Linux / Unix (SystemV ABI)
# ========================================================

# ========================================================
# Function: @write
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 80 bytes
#   arg[0] -> -8(%rbp)
#   arg[1] -> -16(%rbp)
# ========================================================
    .text
.globl write
.type write, @function
write:
    pushq %rbp
    movq %rsp, %rbp
    subq $80, %rsp
    movq %rdi, -8(%rbp)
    movq %rsi, -16(%rbp)
.Lwrite_BB4:
    movq -16(%rbp), %rax
    movq -8(%rbp), %rcx
    movq %rax, (%rcx)
    jmp .Lwrite_epilogue
.Lwrite_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @main
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 80 bytes
# ========================================================
    .text
.globl main
.type main, @function
main:
    pushq %rbp
    movq %rsp, %rbp
    subq $80, %rsp
.Lmain_BB8:
    movabsq $5, %rax
    jmp .Lmain_epilogue
.Lmain_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq


