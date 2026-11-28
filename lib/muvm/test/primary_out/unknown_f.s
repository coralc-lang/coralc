# ========================================================
# Module: aa_unknown
# Target OS: Linux / Unix (SystemV ABI)
# ========================================================

# ========================================================
# Function: @main
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 144 bytes
#   arg[0] -> -8(%rbp)
# ========================================================
    .text
.globl main
.type main, @function
main:
    pushq %rbp
    movq %rsp, %rbp
    subq $144, %rsp
    movq %rdi, -8(%rbp)
.Lmain_BB3:
    leaq -16(%rbp), %rax
    movq %rax, -24(%rbp)
    leaq -32(%rbp), %rax
    movq %rax, -40(%rbp)
    movq -40(%rbp), %rax
    movq -24(%rbp), %rcx
    movq %rax, (%rcx)
    movq -24(%rbp), %rax
    movq (%rax), %rcx
    movq %rcx, -48(%rbp)
    movq -48(%rbp), %rax
    movq (%rax), %rcx
    movq %rcx, -56(%rbp)
    movq -56(%rbp), %rax
    movq %rax, -64(%rbp)
    movq -64(%rbp), %rax
    jmp .Lmain_epilogue
.Lmain_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq


