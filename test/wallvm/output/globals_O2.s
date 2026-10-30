.section .text
.globl main
.type main, @function
main:
.Lmain_entry_7:
	leaq counter(%rip), %rdx
	movq (%rdx), %rsi
	leaq answer(%rip), %rdx
	movq (%rdx), %rdi
	addq %rdi, %rsi
	leaq counter(%rip), %rdx
	movq %rsi, (%rdx)
	leaq alias(%rip), %rdx
	movq (%rdx), %rsi
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
