.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	subq $16, %rsp
	leaq -32(%rbp), %rsi
	leaq (%rsi), %rdi
	leaq 8(%rsi), %r8
	movl $0x0000000000000007, (%rdi)
	movq $0x0000000000000032, (%r8)
	movl (%rdi), %esi
	movl %esi, %edi
	movq (%r8), %rsi
	movq %rdi, %rbx
	addq %rsi, %rbx
	xorq %rbx, %rdi
	xorq %rbx, %rsi
	andq %rsi, %rdi
	movq %rdi, %r12
	movq $0x000000000000003f, %rcx
	sarq %cl, %r12
	movq $0x0000000000000003, %rdi
	movq %r12, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs20(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs19(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq %rbx, %rax
	addq $16, %rsp
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata,"a",@progbits
.Lcs19:
	.asciz "main"
.Lcs20:
	.asciz "?"
