# ========================================================
# Module: aa_two_globals
# Target OS: Linux / Unix (SystemV ABI)
# ========================================================

# ---- Global Variables ----
    .data
    .align 8
.globl g1
g1:
    .quad 1
    .data
    .align 8
.globl g2
g2:
    .quad 2

# ========================================================
# Function: @main
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 96 bytes
# ========================================================
    .text
.globl main
.type main, @function
main:
    pushq %rbp
    movq %rsp, %rbp
    subq $96, %rsp
.Lmain_BB6:
    movabsq $7, %rax
    leaq g1(%rip), %rcx
    movq %rax, (%rcx)
    leaq g2(%rip), %rax
    movq (%rax), %rcx
    movq %rcx, -8(%rbp)
    movq -8(%rbp), %rax
    movq %rax, -16(%rbp)
    movq -16(%rbp), %rax
    jmp .Lmain_epilogue
.Lmain_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq


