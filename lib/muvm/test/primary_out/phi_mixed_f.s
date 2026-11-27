# ========================================================
# Module: aa_phi_mixed
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
    movq -8(%rbp), %rax
    movabsq $0, %rcx
    cmpq %rcx, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, -48(%rbp)
    movq -24(%rbp), %rax
    movq %rax, -56(%rbp)
    movq -48(%rbp), %rax
    testq %rax, %rax
    jne .Lmain_BB6
    jmp .Lmain_BB5
.Lmain_BB5:
    movq -40(%rbp), %rax
    movq %rax, -56(%rbp)
    jmp .Lmain_BB6
.Lmain_BB6:
    movq -56(%rbp), %rax
    movq (%rax), %rcx
    movq %rcx, -64(%rbp)
    movq -64(%rbp), %rax
    movq %rax, -72(%rbp)
    movq -72(%rbp), %rax
    jmp .Lmain_epilogue
.Lmain_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq


