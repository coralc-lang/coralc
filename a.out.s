.text
    .globl main
main:
    push %rbp
    mov %rsp, %rbp
    sub $24, %rsp
.LBB0:
    sub $8, %rsp
    lea (%rsp), %rax
    movq %rax, -8(%rbp)
    movq -8(%rbp), %rax
    mov %rax, %rsi
    mov %rsi, %rdi
    mov %rdi, %rax
    mov %rax, %rsi
    mov %rsi, %rcx
    mov $7, %rax
    movq %rax, (%rcx)
    sub $8, %rsp
    lea (%rsp), %rax
    movq %rax, -16(%rbp)
    sub $8, %rsp
    movq -8(%rbp), %rax
    push %rax
    pop %rdi
    call P__get
    mov %rax, %rsi
    add $8, %rsp
    movq -16(%rbp), %rcx
    mov %rsi, %rax
    movl %eax, (%rcx)
    sub $8, %rsp
    lea (%rsp), %rax
    movq %rax, -24(%rbp)
    sub $8, %rsp
    call P__five
    mov %rax, %rsi
    add $8, %rsp
    movq -24(%rbp), %rcx
    mov %rsi, %rax
    movl %eax, (%rcx)
    movq -16(%rbp), %rax
    movl (%rax), %esi
    mov %rsi, %rdi
    mov $7, %rcx
    cmp %rcx, %rdi
    setne %dil
    movzbl %dil, %edi
    mov %rdi, %rax
    movzbl %al, %eax
    test %rax, %rax
    jnz .LBB1
    jmp .LBB2

.LBB1:
    mov $1, %rax
    mov %rbp, %rsp
    pop %rbp
    ret

.LBB2:
    movq -24(%rbp), %rax
    movl (%rax), %esi
    mov %rsi, %rdi
    mov $5, %rcx
    cmp %rcx, %rdi
    setne %dil
    movzbl %dil, %edi
    mov %rdi, %rax
    movzbl %al, %eax
    test %rax, %rax
    jnz .LBB3
    jmp .LBB4

.LBB3:
    mov $2, %rax
    mov %rbp, %rsp
    pop %rbp
    ret

.LBB4:
    mov $0, %rax
    mov %rbp, %rsp
    pop %rbp
    ret

    .globl P__get
P__get:
    push %rbp
    mov %rsp, %rbp
.LBB5:
    sub $8, %rsp
    lea (%rsp), %rsi
    mov %rsi, %rcx
    mov %rdi, (%rcx)
    mov %rsi, %rax
    movq (%rax), %rdi
    mov %rdi, %rax
    mov %rax, %rsi
    mov %rsi, %rdi
    mov %rdi, %rax
    mov %rax, %rsi
    mov %rsi, %rax
    movl (%rax), %edi
    mov %rdi, %rax
    mov %rbp, %rsp
    pop %rbp
    ret

    .globl P__five
P__five:
    push %rbp
    mov %rsp, %rbp
.LBB6:
    mov $5, %rax
    mov %rbp, %rsp
    pop %rbp
    ret

