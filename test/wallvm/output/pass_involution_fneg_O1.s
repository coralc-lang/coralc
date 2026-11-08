.section .text
.globl main
.type main, @function
main:
	movq g(%rip), %xmm2
	andpd .Lfabs_mask_d, %xmm2
	movsd %xmm2, %xmm3
	cvttsd2si %xmm3, %rsi
	movq %rsi, %rax
	ret
.section .data
	.balign 8
g:
	.quad 0xc00c000000000000
.section .data
.Lfabs_mask_d:
	.quad 0x7fffffffffffffff, 0
