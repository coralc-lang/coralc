.section .rodata
.LC0:
    .string "MyNode"
.LC1:
    .string "Node"
.text
    .globl makeName
makeName:
    push %rbp
    mov %rsp, %rbp
    sub $64, %rsp
    movq %rdi, -40(%rbp)
.LBB0:
    lea -48(%rbp), %r9
    movq -40(%rbp), %rax
    movq %rax, (%r9)
    lea -56(%rbp), %rdi
    mov %rsi, %rax
    movq %rax, (%rdi)
    lea -64(%rbp), %rax
    movq %rax, -32(%rbp)
    mov %rsi, %rax
    movsbl %al, %eax
    mov %rax, %rdi
    movq -32(%rbp), %rcx
    mov %rdi, %rax
    movq %rax, (%rcx)
    movq (%rdi), %rax
    movq %rax, -24(%rbp)
    movq -32(%rbp), %rax
    movq (%rax), %rax
    movq %rax, -16(%rbp)
    movq (%r9), %rax
    movq %rax, -8(%rbp)
    movq -16(%rbp), %rdi
    movq -8(%rbp), %rsi
    movq -24(%rbp), %rax
    call *%rax
    movq -32(%rbp), %rax
    movq (%rax), %rsi
    mov %rsi, %rax
    mov %rbp, %rsp
    pop %rbp
    ret

    .globl mySet
mySet:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
    movq %rdi, -8(%rbp)
    movq %rsi, -16(%rbp)
    movq %rdx, -24(%rbp)
.LBB1:
    lea -32(%rbp), %rsi
    movq -8(%rbp), %rax
    movq %rax, (%rsi)
    lea -40(%rbp), %rsi
    movq -16(%rbp), %rax
    movq %rax, (%rsi)
    lea -48(%rbp), %rsi
    movq -24(%rbp), %rax
    movq %rax, (%rsi)
    mov $1, %rax
    mov %rbp, %rsp
    pop %rbp
    ret

    .globl myGet
myGet:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
    movq %rdi, -8(%rbp)
    movq %rsi, -16(%rbp)
    movq %rdx, -24(%rbp)
.LBB2:
    lea -32(%rbp), %rdi
    movq -8(%rbp), %rax
    movq %rax, (%rdi)
    lea -40(%rbp), %rsi
    movq -16(%rbp), %rax
    movq %rax, (%rsi)
    lea -48(%rbp), %rsi
    movq -24(%rbp), %rax
    movq %rax, (%rsi)
    mov $1, %rax
    mov %rbp, %rsp
    pop %rbp
    ret

    .globl myCreate
myCreate:
    push %rbp
    mov %rsp, %rbp
    sub $16, %rsp
    movq %rdi, -8(%rbp)
.LBB3:
    lea -16(%rbp), %rdi
    movq -8(%rbp), %rax
    movq %rax, (%rdi)
    mov $0, %rax
    mov %rbp, %rsp
    pop %rbp
    ret

    .globl myFree
myFree:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    movq %rdi, -8(%rbp)
    movq %rsi, -16(%rbp)
.LBB4:
    lea -24(%rbp), %rdi
    movq -8(%rbp), %rax
    movq %rax, (%rdi)
    lea -32(%rbp), %rsi
    movq -16(%rbp), %rax
    movq %rax, (%rsi)
    mov %rbp, %rsp
    pop %rbp
    ret

    .globl registerMyClass
registerMyClass:
    push %rbp
    mov %rsp, %rbp
    sub $120, %rsp
    movq %rdi, -80(%rbp)
.LBB5:
    lea -88(%rbp), %rax
    movq %rax, -64(%rbp)
    movq -64(%rbp), %rcx
    movq -80(%rbp), %rax
    movq %rax, (%rcx)
    lea -96(%rbp), %rax
    movq %rax, -56(%rbp)
    movq -56(%rbp), %rcx
    mov %rsi, %rax
    movq %rax, (%rcx)
    lea -104(%rbp), %rax
    movq %rax, -72(%rbp)
    lea -112(%rbp), %rax
    movq %rax, -48(%rbp)
    sub $8, %rsp
    leaq .LC0(%rip), %rdi
    call makeName
    mov %rax, %rdi
    add $8, %rsp
    movq -48(%rbp), %rcx
    mov %rdi, %rax
    movq %rax, (%rcx)
    lea -120(%rbp), %rax
    movq %rax, -40(%rbp)
    sub $8, %rsp
    leaq .LC1(%rip), %rdi
    call makeName
    mov %rax, %rdi
    add $8, %rsp
    movq -40(%rbp), %rcx
    mov %rdi, %rax
    movq %rax, (%rcx)
    movq -56(%rbp), %rax
    movq (%rax), %rax
    movq %rax, -32(%rbp)
    movq -64(%rbp), %rax
    movq (%rax), %rax
    movq %rax, -24(%rbp)
    movq -48(%rbp), %rax
    movq (%rax), %rax
    movq %rax, -16(%rbp)
    movq -40(%rbp), %rax
    movq (%rax), %rax
    movq %rax, -8(%rbp)
    sub $8, %rsp
    movq -24(%rbp), %rdi
    movq -16(%rbp), %rsi
    movq -8(%rbp), %rdx
    movq -72(%rbp), %rcx
    movq -32(%rbp), %rax
    call *%rax
    add $8, %rsp
    mov $1, %eax
    mov %rbp, %rsp
    pop %rbp
    ret

