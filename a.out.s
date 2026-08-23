.section .rodata
.LC0:
    .string "\t32232\t"
.text
    .globl main
main:
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp
.LBB0:
    movabs $4614257573814616457, %rax
    movq %rax, -8(%rbp)
    movq -8(%rbp), %xmm0
    sub $8, %rsp
    mov $1024, %rax
    push %rax
    leaq .LC0(%rip), %rax
    push %rax
    pop %rsi
    pop %rdi
    mov $0, %rax
    call *%rax
    add $8, %rsp
    mov $0, %rax
    mov %rbp, %rsp
    pop %rbp
    ret

