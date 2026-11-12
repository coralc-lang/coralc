.section .text
.globl main
.type main, @function
main:
.L5:
	movl g(%rip), %esi
	cmpl $0x0000000000000032, %esi
	jl .L7
.L6:
	movq $0x0000000000000007, %rax
	ret
.L7:
	movq $0x0000000000000003, %rax
	ret
.section .data
	.balign 4
g:
	.long 0x0000000000000000
