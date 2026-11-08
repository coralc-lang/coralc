.section .text
.globl main
.type main, @function
main:
	movl g(%rip), %edi
	cmpl $0x0000000000000005, %edi
	je .L7
.L6:
.L7:
	movl $0x0000000000000001, %r10d
	movl %r10d, %esi
	addl %edi, %esi
	movq %rsi, %rax
	ret
.section .data
	.balign 4
g:
	.long 0x0000000000000007
