.text
    .globl printf

    .globl main
main:
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp
.LBB0:
    sub $8, %rsp
    lea (%rsp), %rsi
    mov %rsi, %rcx
    mov $45, %rax
    movq %rax, (%rcx)
    sub $8, %rsp
    lea (%rsp), %rdi
    mov %rdi, %rcx
    mov $0, %rax
    movq %rax, (%rcx)
    jmp .LBB1

.LBB1:
    mov %rdi, %rax
    movl (%rax), %r8d
    mov %rsi, %rax
    movl (%rax), %r9d
    mov %r8, %r10
    mov %r9, %rcx
    cmp %rcx, %r10
    setl %r10b
    movzbl %r10b, %r10d
    mov %r10, %rax
    movzbl %al, %eax
    test %rax, %rax
    jnz .LBB2
    jmp .LBB3

.LBB2:
    mov %rsi, %rax
    movl (%rax), %r8d
    mov %rdi, %rax
    movl (%rax), %r9d
    mov %r8, %r10
    mov %r9, %rcx
    add %ecx, %r10d
    mov %rsi, %rcx
    mov %r10, %rax
    movl %eax, (%rcx)
    mov %rdi, %rax
    movl (%rax), %r8d
    mov %r8, %r9
    add $1, %r9d
    mov %rdi, %rcx
    mov %r9, %rax
    movl %eax, (%rcx)
    jmp .LBB1

.LBB3:
    mov %rsi, %rax
    movl (%rax), %eax
    movq %rax, -8(%rbp)
    sub $8, %rsp
    mov $0, %rax
    push %rax
    movq -8(%rbp), %rax
    push %rax
    pop %rsi
    pop %rdi
    call printf
    mov %rax, %rsi
    add $8, %rsp
    mov $0, %rax
    mov %rbp, %rsp
    pop %rbp
    ret

