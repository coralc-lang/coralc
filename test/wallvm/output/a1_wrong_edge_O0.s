.section .text
.globl main
.type main, @function
main:
	movl gx(%rip), %esi
	movl gy(%rip), %edi
	cmpl %edi, %esi
	jge .L8
.L7:
	cmpl %edi, %esi
	jl .L9
.L8:
	movq $0x0000000000000002, %rax
	ret
.L9:
	movq $0x0000000000000001, %rax
	ret
.section .data
	.balign 4
gx:
	.long 0x0000000000000003
	.balign 4
gy:
	.long 0x000000000000000a
