# ========================================================
# Module: aa_phi_mutual
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
    movq -8(%rbp), %rax
    movabsq $10, %rcx
    cmpq %rcx, %rax
    setl %al
    movzbq %al, %rax
    movq %rax, -32(%rbp)
    movq -48(%rbp), %rax
    movq %rax, -136(%rbp)
    movq -40(%rbp), %rax
    movq %rax, -128(%rbp)
    movq -136(%rbp), %rax
    movq %rax, -40(%rbp)
    movq -128(%rbp), %rax
    movq %rax, -48(%rbp)
    jmp .Lmain_BB6
.Lmain_BB6:
    movq -32(%rbp), %rax
    testq %rax, %rax
    jne .Lmain_BB6
    jmp .Lmain_BB7
.Lmain_BB7:
    movq -40(%rbp), %rax
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


