# ========================================================
# Module: aa_basic
# Target OS: Linux / Unix (SystemV ABI)
# ========================================================

# ========================================================
# Function: @main
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 144 bytes
# ========================================================
    .text
.globl main
.type main, @function
main:
    pushq %rbp
    movq %rsp, %rbp
    subq $144, %rsp
.Lmain_BB2:
    leaq -8(%rbp), %rax
    movq %rax, -16(%rbp)
    movq -16(%rbp), %rax
    addq $1, %rax
    movq %rax, -24(%rbp)
    movabsq $1, %rax
    movq -16(%rbp), %rcx
    movq %rax, (%rcx)
    movabsq $2, %rax
    movq -24(%rbp), %rcx
    movq %rax, (%rcx)
    movq -16(%rbp), %rax
    movq (%rax), %rcx
    movq %rcx, -32(%rbp)
    movq -16(%rbp), %rax
    movq %rax, -40(%rbp)
    movq -40(%rbp), %rax
    movq (%rax), %rcx
    movq %rcx, -48(%rbp)
    movq -32(%rbp), %rax
    movabsq $3, %rcx
    addq %rcx, %rax
    movq %rax, -56(%rbp)
    movq -48(%rbp), %rax
    movq -56(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -64(%rbp)
    movq -64(%rbp), %rax
    movq %rax, -72(%rbp)
    movq -72(%rbp), %rax
    jmp .Lmain_epilogue
.Lmain_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq


