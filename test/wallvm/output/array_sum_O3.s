.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $56, %rsp
	leaq -64(%rbp), %rsi
	jmp .L53
.L8:
	movl %r8d, %edi
	movq %rdi, %rax
	addq $56, %rsp
	popq %rbx
	leave
	ret
.L53:
	leaq (%rsi), %rdi
	movq $0x0000000000000001, (%rdi)
.L55:
	leaq 8(%rsi), %rdi
	movq $0x0000000000000002, (%rdi)
.L57:
	leaq 16(%rsi), %rdi
	movq $0x0000000000000003, (%rdi)
.L59:
	leaq 24(%rsi), %rdi
	movq $0x0000000000000004, (%rdi)
.L61:
	leaq 32(%rsi), %rdi
	movq $0x0000000000000005, (%rdi)
	leaq (%rsi), %r8
	movq (%r8), %rdi
	movq %rdi, %rbx
	leaq 8(%rsi), %r8
	movq (%r8), %rdi
	movq %rdi, %r9
	addq %rbx, %r9
	leaq 16(%rsi), %r8
	movq (%r8), %rdi
	movq %rdi, %rbx
	addq %r9, %rbx
	leaq 24(%rsi), %r8
	movq (%r8), %rdi
	movq %rdi, %r9
	addq %rbx, %r9
	leaq 32(%rsi), %r8
	movq (%r8), %rdi
	movq %rdi, %rsi
	addq %r9, %rsi
	movq %rsi, %r8
	jmp .L8
