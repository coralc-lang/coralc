# ========================================================
# Module: nestflag
# Target OS: Linux / Unix (SystemV ABI)
# ========================================================

# ========================================================
# Function: @nest
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 144 bytes
#   arg[0] -> -8(%rbp)
# ========================================================
    .text
.globl nest
.type nest, @function
nest:
    pushq %rbp
    movq %rsp, %rbp
    subq $144, %rsp
    movq %rdi, -8(%rbp)
.Lnest_BB3:
    movq -8(%rbp), %rax
    movabsq $7, %rcx
    cmpq %rcx, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, -16(%rbp)
    movabsq $0, %rax
    movq %rax, -24(%rbp)
    movabsq $0, %rax
    movq %rax, -32(%rbp)
    movabsq $0, %rax
    movq %rax, -40(%rbp)
    jmp .Lnest_BB4
.Lnest_BB4:
    movq -24(%rbp), %rax
    movabsq $3, %rcx
    cmpq %rcx, %rax
    setl %al
    movzbq %al, %rax
    movq %rax, -48(%rbp)
    movq -24(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -56(%rbp)
    movabsq $0, %rax
    movq %rax, -64(%rbp)
    movabsq $0, %rax
    movq %rax, -72(%rbp)
    movq -48(%rbp), %rax
    testq %rax, %rax
    jne .Lnest_BB6
    jmp .Lnest_BB13
.Lnest_BB6:
    jmp .Lnest_BB7
.Lnest_BB7:
    movq -72(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -80(%rbp)
    movq -80(%rbp), %rax
    movq %rax, -96(%rbp)
    movq -16(%rbp), %rax
    testq %rax, %rax
    jne .Lnest_BB10
    jmp .Lnest_BB9
.Lnest_BB9:
    movq -72(%rbp), %rax
    movabsq $2, %rcx
    addq %rcx, %rax
    movq %rax, -88(%rbp)
    movq -88(%rbp), %rax
    movq %rax, -96(%rbp)
    jmp .Lnest_BB10
.Lnest_BB10:
    jmp .Lnest_BB11
.Lnest_BB11:
    movq -64(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -104(%rbp)
    movq -104(%rbp), %rax
    movabsq $4, %rcx
    cmpq %rcx, %rax
    setl %al
    movzbq %al, %rax
    movq %rax, -112(%rbp)
    movq -104(%rbp), %rax
    movq %rax, -64(%rbp)
    movq -96(%rbp), %rax
    movq %rax, -72(%rbp)
    movq -56(%rbp), %rax
    movq %rax, -24(%rbp)
    movq -64(%rbp), %rax
    movq %rax, -32(%rbp)
    movq -72(%rbp), %rax
    movq %rax, -40(%rbp)
    movq -112(%rbp), %rax
    testq %rax, %rax
    jne .Lnest_BB6
    jmp .Lnest_BB4
.Lnest_BB13:
    movq -32(%rbp), %rax
    movabsq $10, %rcx
    imulq %rcx, %rax
    movq %rax, -120(%rbp)
    movq -120(%rbp), %rax
    movq -24(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -128(%rbp)
    movq -128(%rbp), %rax
    movq -40(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -136(%rbp)
    movq -136(%rbp), %rax
    jmp .Lnest_epilogue
.Lnest_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

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
.Lmain_BB49:
    movabsq $0, %rax
    movq %rax, -8(%rbp)
    movabsq $0, %rax
    movq %rax, -16(%rbp)
    movabsq $0, %rax
    movq %rax, -24(%rbp)
    jmp .Lmain_BB87
.Lmain_BB87:
    movq -8(%rbp), %rax
    movabsq $3, %rcx
    cmpq %rcx, %rax
    setl %al
    movzbq %al, %rax
    movq %rax, -32(%rbp)
    movq -8(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -40(%rbp)
    movq -16(%rbp), %rax
    movabsq $10, %rcx
    imulq %rcx, %rax
    movq %rax, -48(%rbp)
    movq -48(%rbp), %rax
    movq -8(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -56(%rbp)
    movq -56(%rbp), %rax
    movq -24(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -64(%rbp)
    movabsq $0, %rax
    movq %rax, -72(%rbp)
    movabsq $0, %rax
    movq %rax, -80(%rbp)
    movq -32(%rbp), %rax
    testq %rax, %rax
    jne .Lmain_BB88
    jmp .Lmain_BB85
.Lmain_BB88:
    movq -80(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -88(%rbp)
    jmp .Lmain_BB92
.Lmain_BB92:
    movq -72(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -96(%rbp)
    movq -96(%rbp), %rax
    movabsq $4, %rcx
    cmpq %rcx, %rax
    setl %al
    movzbq %al, %rax
    movq %rax, -104(%rbp)
    movq -96(%rbp), %rax
    movq %rax, -72(%rbp)
    movq -88(%rbp), %rax
    movq %rax, -80(%rbp)
    movq -40(%rbp), %rax
    movq %rax, -8(%rbp)
    movq -72(%rbp), %rax
    movq %rax, -16(%rbp)
    movq -80(%rbp), %rax
    movq %rax, -24(%rbp)
    movq -104(%rbp), %rax
    testq %rax, %rax
    jne .Lmain_BB88
    jmp .Lmain_BB87
.Lmain_BB85:
    movq -64(%rbp), %rax
    movq %rax, -112(%rbp)
    movq -112(%rbp), %rax
    jmp .Lmain_epilogue
.Lmain_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq


