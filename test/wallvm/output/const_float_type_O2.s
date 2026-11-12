.section .text
.globl main
.type main, @function
main:
	movl g(%rip), %esi
	cvtsi2sd %rsi, %xmm2
	addsd	.Lcf11(%rip), %xmm2
	cvttsd2si %xmm2, %rsi
	movl $0x0000000000000003, %r11d
	addl %r11d, %esi
	movq %rsi, %rax
	ret
.section .rodata.cst8,"aM",@progbits,8
	.balign 8
.Lcf11:
	.quad 0x3ff0000000000000
.section .data
	.balign 4
g:
	.long 0x0000000000000003
