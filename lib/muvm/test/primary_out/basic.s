    .text
.globl main
.type main, @function
main:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rbx
    pushq %r12
    subq $32, %rsp
.Lmain_BB2:
    leaq -32(%rbp), %rdi
    leaq -48(%rbp), %rbx
    movq %rdi, %r8
    movq %rdi, %r12
    addq $1, %r12
    movq %rbx, %rsi
    movq $1, (%r8)
    movq $2, (%r12)
    movq $3, (%rsi)
    movq (%r8), %r9
    movq (%rsi), %r8
    movq %rdi, %rsi
    movq (%rsi), %rdi
    movq %r9, %rsi
    addq %r8, %rsi
    movq %rsi, %r8
    addq %rdi, %r8
    movq %r8, %rdi
    movl %edi, %eax
    leaq -16(%rbp), %rsp
    pop %r12
    pop %rbx
    popq %rbp
    ret
    .size main, . - main


