.section .rodata
.LC0:
    .string "\t32232\t"
.text
    .globl main
main:
    push %rbp
    mov %rsp, %rbp
.LBB0:
    leaq .LC0(%rip), %rdi
    mov $0, %rax
    call *%rax
    mov $0, %rax
    mov %rbp, %rsp
    pop %rbp
    ret

