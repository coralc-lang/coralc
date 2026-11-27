# ========================================================
# Module: aa_gep_var
# Target OS: Linux / Unix (SystemV ABI)
# ========================================================

# ========================================================
# Function: @main
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 176 bytes
#   arg[0] -> -8(%rbp)
# ========================================================
    .text
.globl main
.type main, @function
main:
    pushq %rbp
    movq %rsp, %rbp
    subq $176, %rsp
    movq %rdi, -8(%rbp)
.Lmain_BB3:
    leaq -72(%rbp), %rax
    movq %rax, -80(%rbp)
    movq -80(%rbp), %rax
    movq -8(%rbp), %rcx
    imulq $8, %rcx, %rcx
    addq %rcx, %rax
    movq %rax, -88(%rbp)
    movq -80(%rbp), %rax
    addq $24, %rax
    movq %rax, -96(%rbp)
    movabsq $1, %rax
    movq -88(%rbp), %rcx
    movq %rax, (%rcx)
    movabsq $2, %rax
    movq -96(%rbp), %rcx
    movq %rax, (%rcx)
    movabsq $2, %rax
    jmp .Lmain_epilogue
.Lmain_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq


