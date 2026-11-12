.section .text
.globl inf
.type inf, @function
inf:
	pushq %rbx
	pushq %r12
	subq $8, %rsp
	call inf
	movq %rax, %rsi
	movq %rsi, %rbx
	addq %rdi, %rbx
	xorq %rbx, %rsi
	movq %rdi, %r8
	xorq %rbx, %r8
	andq %r8, %rsi
	movq %rsi, %r12
	movq $0x000000000000003f, %rcx
	sarq %cl, %r12
	movq $0x0000000000000003, %rdi
	movq %r12, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs14(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs13(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq %rbx, %rax
	addq $8, %rsp
	popq %r12
	popq %rbx
	ret
.globl main
.type main, @function
main:
	movq $0x0000000000000000, %rax
	ret
.section .rodata,"a",@progbits
.Lcs13:
	.asciz "inf"
.Lcs14:
	.asciz "?"
