# ========================================================
# Module: aa_basic
# Target OS: Linux / Unix (SystemV ABI)
# ========================================================

# ========================================================
# Function: @main
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 192 bytes
# ========================================================
    .text
.globl main
.type main, @function
main:
    pushq %rbp
    movq %rsp, %rbp
    subq $192, %rsp
.Lmain_BB2:
    leaq -8(%rbp), %rax
    movq %rax, -16(%rbp)
    leaq -24(%rbp), %rax
    movq %rax, -32(%rbp)
    movq -16(%rbp), %rax
    movq %rax, -40(%rbp)
    movq -16(%rbp), %rax
    addq $1, %rax
    movq %rax, -48(%rbp)
    movq -32(%rbp), %rax
    movq %rax, -56(%rbp)
    movabsq $1, %rax
    movq -40(%rbp), %rcx
    movq %rax, (%rcx)
    movabsq $2, %rax
    movq -48(%rbp), %rcx
    movq %rax, (%rcx)
    movabsq $3, %rax
    movq -56(%rbp), %rcx
    movq %rax, (%rcx)
    movq -40(%rbp), %rax
    movq (%rax), %rcx
    movq %rcx, -64(%rbp)
    movq -56(%rbp), %rax
    movq (%rax), %rcx
    movq %rcx, -72(%rbp)
    movq -16(%rbp), %rax
    movq %rax, -80(%rbp)
    movq -80(%rbp), %rax
    movq (%rax), %rcx
    movq %rcx, -88(%rbp)
    movq -64(%rbp), %rax
    movq -72(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -96(%rbp)
    movq -96(%rbp), %rax
    movq -88(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -104(%rbp)
    movq -104(%rbp), %rax
    movq %rax, -112(%rbp)
    movq -112(%rbp), %rax
    jmp .Lmain_epilogue
.Lmain_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq


