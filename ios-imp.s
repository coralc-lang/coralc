.section .rodata
.LC0:
    .string "%f"
.text
    .globl pow
pow:
    push %rbp
    mov %rsp, %rbp
    sub $64, %rsp
    movq %xmm0, -16(%rbp)
    movq %rdi, -24(%rbp)
.LBB0:
    lea -40(%rbp), %rax
    movq %rax, -8(%rbp)
    movq -8(%rbp), %rcx
    movq -16(%rbp), %xmm0
    movq %xmm0, (%rcx)
    lea -48(%rbp), %r9
    mov %r9, %rcx
    movq -24(%rbp), %rax
    movq %rax, (%rcx)
    lea -56(%rbp), %r11
    mov %r11, %rcx
    mov $1, %rax
    movq %rax, (%rcx)
    lea -64(%rbp), %r10
    mov %r10, %rcx
    mov $0, %rax
    movq %rax, (%rcx)
    jmp .LBB1

.LBB1:
    mov %r10, %rax
    movl (%rax), %r8d
    mov %r9, %rax
    movq (%rax), %rsi
    mov %r8, %rdi
    mov %rsi, %rcx
    cmp %rcx, %rdi
    setl %dil
    movzbl %dil, %edi
    mov %rdi, %rax
    movzbl %al, %eax
    test %rax, %rax
    jnz .LBB2
    jmp .LBB3

.LBB2:
    mov %r11, %rax
    movq (%rax), %rax
    movq %rax, %xmm4
    movq -8(%rbp), %rax
    movq (%rax), %rax
    movq %rax, %xmm3
    movq %xmm4, %xmm0
    movq %xmm3, %xmm1
    addsd %xmm1, %xmm0
    movq %xmm0, %xmm4
    mov %r11, %rcx
    movq %xmm4, %xmm0
    movq %xmm0, (%rcx)
    mov %r10, %rax
    movl (%rax), %esi
    mov %rsi, %rdi
    add $1, %edi
    mov %r10, %rcx
    mov %rdi, %rax
    movl %eax, (%rcx)
    jmp .LBB1

.LBB3:
    mov %r11, %rax
    movq (%rax), %rax
    movq %rax, %xmm3
    movq %xmm3, %xmm0
    mov %rbp, %rsp
    pop %rbp
    ret

    .globl printf

    .globl main
main:
    push %rbp
    mov %rsp, %rbp
.LBB4:
    mov $2, %rdi
    mov $10, %rsi
    call pow
    movq %xmm0, %xmm3
    movq %xmm3, %xmm0
    mov $0, %rax
    push %rax
    pop %rdi
    call printf
    mov %rax, %rsi
    mov $0, %rax
    mov %rbp, %rsp
    pop %rbp
    ret

