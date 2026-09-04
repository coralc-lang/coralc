    .file "tests_borrow_check1.crl"
.text
    .p2align 4
    .globl bad1
    .type bad1, @function
bad1:
    .cfi_startproc
    push %rbp
    .cfi_def_cfa_offset 16
    .cfi_offset 6, -16
    mov %rsp, %rbp
    .cfi_def_cfa_register 6
    sub $16, %rsp
.LBB0:
    mov %rsi, %rax
    movq %rax, -8(%rbp)
    mov %rsi, %rax
    add $1, %rax
    movq %rax, -16(%rbp)
    movq -8(%rbp), %rdi
    movq -16(%rbp), %rsi
    mov $32, %rdx
    call memcpy@PLT
    mov %rbp, %rsp
    .cfi_def_cfa 7, 8
    pop %rbp
    ret
    .cfi_endproc
    .size bad1, . - bad1

    .p2align 4
    .globl bad2
    .type bad2, @function
bad2:
    .cfi_startproc
    push %rbp
    .cfi_def_cfa_offset 16
    .cfi_offset 6, -16
    mov %rsp, %rbp
    .cfi_def_cfa_register 6
.LBB1:
    movl (%rsi), %esi
    mov $42, %rax
    movq %rax, (%rsi)
    mov %rsi, %rax
    mov %rbp, %rsp
    .cfi_def_cfa 7, 8
    pop %rbp
    ret
    .cfi_endproc
    .size bad2, . - bad2

    .p2align 4
    .globl writeThrough
    .type writeThrough, @function
writeThrough:
    .cfi_startproc
    push %rbp
    .cfi_def_cfa_offset 16
    .cfi_offset 6, -16
    mov %rsp, %rbp
    .cfi_def_cfa_register 6
.LBB2:
    mov %rbp, %rsp
    .cfi_def_cfa 7, 8
    pop %rbp
    ret
    .cfi_endproc
    .size writeThrough, . - writeThrough

    .p2align 4
    .globl bad3
    .type bad3, @function
bad3:
    .cfi_startproc
    push %rbp
    .cfi_def_cfa_offset 16
    .cfi_offset 6, -16
    mov %rsp, %rbp
    .cfi_def_cfa_register 6
    sub $16, %rsp
.LBB3:
    mov %rsi, %rax
    movq %rax, -8(%rbp)
    movl (%rax), %eax
    movq %rax, -16(%rbp)
    mov %rsi, %rdi
    call writeThrough
    movq -16(%rbp), %rsi
    add $1, %esi
    mov %rsi, %rax
    mov %rbp, %rsp
    .cfi_def_cfa 7, 8
    pop %rbp
    ret
    .cfi_endproc
    .size bad3, . - bad3

    .p2align 4
    .globl main
    .type main, @function
main:
    .cfi_startproc
    push %rbp
    .cfi_def_cfa_offset 16
    .cfi_offset 6, -16
    mov %rsp, %rbp
    .cfi_def_cfa_register 6
    sub $56, %rsp
.LBB4:
    lea -40(%rbp), %rax
    movq %rax, -16(%rbp)
    mov $5, %rax
    movq %rax, -40(%rbp)
    sub $8, %rsp
    movq -16(%rbp), %rdi
    call bad1
    add $8, %rsp
    lea -48(%rbp), %rax
    movq %rax, -32(%rbp)
    movq -16(%rbp), %rax
    movq %rax, -8(%rbp)
    sub $8, %rsp
    movq -8(%rbp), %rdi
    call bad2
    mov %rax, %rdi
    add $8, %rsp
    movl %edi, -48(%rbp)
    lea -56(%rbp), %rax
    movq %rax, -24(%rbp)
    sub $8, %rsp
    movq -32(%rbp), %rdi
    call bad3
    mov %rax, %rdi
    add $8, %rsp
    movl %edi, -56(%rbp)
    sub $8, %rsp
    movq -24(%rbp), %rdi
    call bad2
    mov %rax, %rsi
    add $8, %rsp
    mov $0, %rax
    mov %rbp, %rsp
    .cfi_def_cfa 7, 8
    pop %rbp
    ret
    .cfi_endproc
    .size main, . - main

