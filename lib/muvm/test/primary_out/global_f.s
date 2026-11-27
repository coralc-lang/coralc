# ========================================================
# Module: aa_global
# Target OS: Linux / Unix (SystemV ABI)
# ========================================================

# ---- Global Variables ----
    .data
    .align 8
.globl g
g:
    .quad 3

# ========================================================
# Function: @main
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 80 bytes
# ========================================================
    .text
.globl main
.type main, @function
main:
    pushq %rbp
    movq %rsp, %rbp
    subq $80, %rsp
.Lmain_BB4:
    movabsq $9, %rax
    leaq g(%rip), %rcx
    movq %rax, (%rcx)
    movabsq $9, %rax
    jmp .Lmain_epilogue
.Lmain_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq


