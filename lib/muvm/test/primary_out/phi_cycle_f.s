# ========================================================
# Module: aa_phi_cycle
# Target OS: Linux / Unix (SystemV ABI)
# ========================================================

# ========================================================
# Function: @main
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 128 bytes
# ========================================================
    .text
.globl main
.type main, @function
main:
    pushq %rbp
    movq %rsp, %rbp
    subq $128, %rsp
.Lmain_BB2:
    leaq -8(%rbp), %rax
    movq %rax, -16(%rbp)
    movq -16(%rbp), %rax
    movq %rax, -24(%rbp)
    jmp .Lmain_BB3
.Lmain_BB3:
    movq -24(%rbp), %rax
    movq (%rax), %rcx
    movq %rcx, -32(%rbp)
    movq -32(%rbp), %rax
    movabsq $7, %rcx
    cmpq %rcx, %rax
    setl %al
    movzbq %al, %rax
    movq %rax, -40(%rbp)
    movq -40(%rbp), %rax
    testq %rax, %rax
    jne .Lmain_BB4
    jmp .Lmain_BB5
.Lmain_BB4:
    movabsq $7, %rax
    movq -24(%rbp), %rcx
    movq %rax, (%rcx)
    movq -24(%rbp), %rax
    movq %rax, -120(%rbp)
    movq -120(%rbp), %rax
    movq %rax, -24(%rbp)
    jmp .Lmain_BB3
.Lmain_BB5:
    movq -32(%rbp), %rax
    movq %rax, -48(%rbp)
    movq -48(%rbp), %rax
    jmp .Lmain_epilogue
.Lmain_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq


