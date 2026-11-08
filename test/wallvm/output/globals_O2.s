.section .text
.globl main
.type main, @function
main:
	movq counter(%rip), %rsi
	movq answer(%rip), %rdi
	addq %rdi, %rsi
	movq %rsi, counter(%rip)
	movq alias(%rip), %rsi
	movq (%rsi), %rdi
	movq %rdi, %rax
	ret
.section .data
	.balign 8
counter:
	.quad 0x000000000000000a
	.balign 8
answer:
	.quad 0x000000000000002a
	.balign 8
alias:
	.quad counter
