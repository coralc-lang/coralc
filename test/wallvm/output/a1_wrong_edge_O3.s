.section .text
.globl main
.type main, @function
main:
.L8:
	movq $0x0000000000000002, %rax
	ret
.section .data
	.balign 4
gx:
	.long 0x0000000000000003
	.balign 4
gy:
	.long 0x000000000000000a
