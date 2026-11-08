.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $48, %rsp
	leaq -48(%rbp), %rsi
	movq idx(%rip), %rdi
	leaq (%rsi, %rdi, 8), %r8
	movq $0x0000000000000007, (%r8)
	movq (%r8), %rsi
	movq $0x0000000000000001, %rcx
	shlq %cl, %rsi
	movq %rsi, %rax
	addq $48, %rsp
	leave
	ret
.section .data
	.balign 8
idx:
	.quad 0x0000000000000000
