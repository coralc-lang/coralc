# ========================================================
# Module: aa_gep_of_phi
# Target OS: Linux / Unix (SystemV ABI)
# ========================================================

# ========================================================
# Function: @main
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 192 bytes
#   arg[0] -> -8(%rbp)
# ========================================================
    .text
.globl main
.type main, @function
main:
    pushq %rbp
    movq %rsp, %rbp
    subq $192, %rsp
    movq %rdi, -8(%rbp)
.Lmain_BB3:
    leaq -40(%rbp), %rax
    movq %rax, -48(%rbp)
    leaq -80(%rbp), %rax
    movq %rax, -88(%rbp)
    movq -8(%rbp), %rax
    movabsq $0, %rcx
    cmpq %rcx, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, -96(%rbp)
    movq -48(%rbp), %rax
    movq %rax, -104(%rbp)
    movq -96(%rbp), %rax
    testq %rax, %rax
    jne .Lmain_BB6
    jmp .Lmain_BB5
.Lmain_BB5:
    movq -88(%rbp), %rax
    movq %rax, -104(%rbp)
    jmp .Lmain_BB6
.Lmain_BB6:
    movq -104(%rbp), %rax
    addq $2, %rax
    movq %rax, -112(%rbp)
    movabsq $9, %rax
    movq -112(%rbp), %rcx
    movq %rax, (%rcx)
    movabsq $9, %rax
    jmp .Lmain_epilogue
.Lmain_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq


