.section .text
.globl main
.type main, @function
main:
	movq z(%rip), %rsi
	movq (%rsi), %rdi
	movq %rdi, %rax
	ret
.section .data
	.balign 8
z:
	.quad 0x0000000000000000
