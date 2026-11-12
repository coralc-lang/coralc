.section .text
.globl main
.type main, @function
main:
	movq $0x000000007fffffff, %rax
	ret
