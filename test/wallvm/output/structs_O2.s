.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp
	leaq -16(%rbp), %rsi
	leaq (%rsi), %rdi
	leaq 8(%rsi), %r8
	movl $0x0000000000000007, (%rdi)
	movq $0x0000000000000032, (%r8)
	movl (%rdi), %esi
	movl %esi, %edi
	movq (%r8), %rsi
	addq %rsi, %rdi
	movq %rdi, %rax
	addq $16, %rsp
	leave
	ret
