.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp
	leaq -16(%rbp), %rsi
	movq %rsi, %rdi
.L3:
	movq (%rdi), %r8
	cmpq $0x0000000000000007, %r8
	jge .L5
.L4:
	movq $0x0000000000000007, (%rdi)
	jmp .L3
.L5:
	movq %r8, %rax
	addq $16, %rsp
	leave
	ret
