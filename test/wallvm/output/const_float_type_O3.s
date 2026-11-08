.section .text
.globl main
.type main, @function
main:
	movl g(%rip), %esi
	cvtsi2sd %rsi, %xmm2
	addsd	%rsi, %xmm2
	cvttsd2si %xmm2, %rdi
	movl $0x0000000000000003, %r10d
	movl %r10d, %esi
	addl %edi, %esi
	movq %rsi, %rax
	ret
.section .data
	.balign 4
g:
	.long 0x0000000000000003
