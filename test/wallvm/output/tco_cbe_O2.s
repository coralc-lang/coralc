.section .text
.globl inf
.type inf, @function
inf:
	call inf
	movq %rax, %rsi
	addq %rdi, %rsi
	movq %rsi, %rax
	ret
.globl main
.type main, @function
main:
	movq $0x0000000000000000, %rax
	ret
