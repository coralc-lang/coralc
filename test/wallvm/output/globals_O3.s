.section .text
.globl main
.type main, @function
main:
.Lmain_entry_7:
	leaq counter(%rip), %rdx
	movq (%rdx), %r8
	leaq answer(%rip), %rdx
	movq (%rdx), %rdi
	movq %r8, %rsi
	addq %rdi, %rsi
	leaq counter(%rip), %rdx
	movq %rsi, (%rdx)
	leaq alias(%rip), %rdx
	movq (%rdx), %rsi
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
