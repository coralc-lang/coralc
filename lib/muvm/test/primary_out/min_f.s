# ========================================================
# Module: aa_min
# Target OS: Linux / Unix (SystemV ABI)
# ========================================================

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
.Lmain_BB2:
    movabsq $1, %rax
    jmp .Lmain_epilogue
.Lmain_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq


