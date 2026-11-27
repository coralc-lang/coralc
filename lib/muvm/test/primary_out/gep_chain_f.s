# ========================================================
# Module: aa_gep_chain
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
    leaq -32(%rbp), %rax
    movq %rax, -40(%rbp)
    movq -40(%rbp), %rax
    movq %rax, -48(%rbp)
    movq -48(%rbp), %rax
    addq $2, %rax
    movq %rax, -56(%rbp)
    movq -56(%rbp), %rax
    addq $1, %rax
    movq %rax, -64(%rbp)
    movabsq $42, %rax
    movq -64(%rbp), %rcx
    movq %rax, (%rcx)
    movabsq $42, %rax
    jmp .Lmain_epilogue
.Lmain_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq


