.section .text
.globl main
.type main, @function
main:
	movq g(%rip), %xmm2
	cvttsd2si %xmm2, %rsi
	cvtsi2sd %rsi, %xmm3
	movsd %xmm3, %xmm0
	ucomisd	%xmm2, %xmm0
	sete %r11b
	setnp %r10b
	and %r10b, %r11b
	movzbq %r11b, %rdi
	movq %rdi, %rsi
	movq %rsi, %rax
	ret
.section .data
	.balign 8
g:
	.quad 0x3ff8000000000000
