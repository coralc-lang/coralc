.section .text
.globl main
.type main, @function
main:
	movd g(%rip), %xmm2
	cvttss2si %xmm2, %rsi
	movq %rsi, %rax
	ret
.section .data
	.balign 4
g:
	.long 0x000000003fc00000
