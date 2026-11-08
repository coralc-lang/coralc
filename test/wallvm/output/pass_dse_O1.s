.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $48, %rsp
	leaq -48(%rbp), %rsi
	leaq (%rsi), %rdi
	movq $0x0000000000000002, (%rdi)
	movq (%rdi), %rsi
	movq %rsi, %rax
	addq $48, %rsp
	leave
	ret
