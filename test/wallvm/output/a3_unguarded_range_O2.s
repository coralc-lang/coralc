.section .text
.globl main
.type main, @function
main:
.L6:
	movq $0x0000000000000007, %rax
	ret
.section .data
	.balign 4
g:
	.long 0x0000000000000000
