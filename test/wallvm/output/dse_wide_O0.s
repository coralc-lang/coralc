.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp
	leaq -16(%rbp), %rsi
	movq $0x0000000000000000, (%rsi)
	movabsq $0x000000aa00000000, %r10
	movq %r10, (%rsi)
	movl $0x0000000000000005, (%rsi)
	movq (%rsi), %rdi
	movq $0x0000000000000020, %rcx
	shrq %cl, %rdi
	movq %rdi, %rax
	addq $16, %rsp
	leave
	ret
