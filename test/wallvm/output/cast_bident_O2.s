.section .text
.globl main
.type main, @function
main:
	movq g(%rip), %rsi
	incq %rsi
	movq %rsi, %rax
	ret
.section .data
	.balign 8
g:
	.quad 0x0000000000000006
