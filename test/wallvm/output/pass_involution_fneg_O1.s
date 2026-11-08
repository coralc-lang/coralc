.section .text
.globl main
.type main, @function
main:
	movq g(%rip), %xmm2
	cvttsd2si %xmm2, %rsi
	movq %rsi, %rax
	ret
.section .data
	.balign 8
g:
	.quad 0xc00c000000000000
