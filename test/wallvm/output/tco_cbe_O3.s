.section .text
.globl inf
.type inf, @function
inf:
	subq $8, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %rsi
	addq $8, %rsp
.L13:
.L16:
	jmp .L13
.globl main
.type main, @function
main:
	movq $0x0000000000000000, %rax
	ret
