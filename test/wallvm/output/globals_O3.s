.section .text
.globl main
.type main, @function
main:
.Lmain_entry_7:
	movq counter(%rip), %r8
	movq answer(%rip), %rdi
	movq %r8, %rsi
	addq %rdi, %rsi
	movq %rsi, counter(%rip)
	movq alias(%rip), %rsi
	movq (%rsi), %rdi
	movl %edi, %esi
	movq %rsi, %rax
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
