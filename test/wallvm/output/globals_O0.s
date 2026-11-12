.section .text
.globl main
.type main, @function
main:
	pushq %rbx
	pushq %r12
	subq $8, %rsp
	movq counter(%rip), %rsi
	movq answer(%rip), %rdi
	movq %rsi, %rbx
	addq %rdi, %rbx
	xorq %rbx, %rsi
	xorq %rbx, %rdi
	andq %rdi, %rsi
	movq %rsi, %r12
	movq $0x000000000000003f, %rcx
	sarq %cl, %r12
	movq $0x0000000000000003, %rdi
	movq %r12, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs19(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs18(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq %rbx, counter(%rip)
	movq alias(%rip), %rbx
	movq $0x0000000000000001, %rdi
	movq %rbx, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs27(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs18(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq (%rbx), %rsi
	movq %rsi, %rax
	addq $8, %rsp
	popq %r12
	popq %rbx
	ret
.section .rodata,"a",@progbits
.Lcs18:
	.asciz "main"
.Lcs19:
	.asciz "?"
.Lcs27:
	.asciz "?"
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
