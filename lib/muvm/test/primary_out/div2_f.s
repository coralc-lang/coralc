# ========================================================
# Module: divt2
# Target OS: Linux / Unix (SystemV ABI)
# ========================================================

# ========================================================
# Function: @main
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 112 bytes
#   arg[0] -> -8(%rbp)
# ========================================================
    .text
.globl main
.type main, @function
main:
    pushq %rbp
    movq %rsp, %rbp
    subq $112, %rsp
    movq %rdi, -8(%rbp)
.Lmain_BB3:
    movq -8(%rbp), %rax
    movabsq $7, %rcx
    cqto
    idivq %rcx
    movq %rax, -16(%rbp)
    movq -8(%rbp), %rax
    movabsq $7, %rcx
    cqto
    idivq %rcx
    movq %rdx, -24(%rbp)
    movq -16(%rbp), %rax
    movq -24(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -32(%rbp)
    movq -32(%rbp), %rax
    movq %rax, -40(%rbp)
    movq -40(%rbp), %rax
    jmp .Lmain_epilogue
.Lmain_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq


