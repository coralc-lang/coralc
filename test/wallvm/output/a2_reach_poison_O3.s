.section .text
.globl main
.type main, @function
main:
	movl g(%rip), %edi
	cmpl $0x0000000000000005, %edi
	je .L7
.L6:
.L7:
	movq $0x0000000000000006, %rax
	ret
.section .data
	.balign 4
g:
	.long 0x0000000000000007
