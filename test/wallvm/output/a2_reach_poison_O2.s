.section .text
.globl main
.type main, @function
main:
	movl g(%rip), %esi
	cmpl $0x0000000000000005, %esi
	jne .L6
.L5:
	jmp .L7
.L6:
.L7:
	incq %rsi
	movq %rsi, %rax
	ret
.section .data
	.balign 4
g:
	.long 0x0000000000000007
