.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	subq $32, %rsp
	leaq -48(%rbp), %rbx
	leaq -64(%rbp), %r12
	movq $0x0000000000000000, (%rbx)
	movq $0x0000000000000000, (%r12)
.L3:
	movq (%rbx), %rsi
	cmpq $0x000000000000000a, %rsi
	jge .L5
.L4:
	movq (%rbx), %rsi
	movq (%r12), %rdi
	movq %rdi, %r13
	addq %rsi, %r13
	xorq %r13, %rdi
	xorq %r13, %rsi
	andq %rsi, %rdi
	movq %rdi, %r14
	movq $0x000000000000003f, %rcx
	sarq %cl, %r14
	movq $0x0000000000000003, %rdi
	movq %r14, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs30(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs29(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq %r13, (%r12)
	movq (%rbx), %rsi
	movq %rsi, %r13
	incq %r13
	xorq %r13, %rsi
	movq %r13, %rdi
	xorq $0x0000000000000001, %rdi
	andq %rdi, %rsi
	movq %rsi, %r14
	movq $0x000000000000003f, %rcx
	sarq %cl, %r14
	movq $0x0000000000000003, %rdi
	movq %r14, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs38(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs29(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	addq $0x0000000000000001, (%rbx)
	jmp .L3
.L5:
	movq (%r12), %rsi
	movq %rsi, %rax
	addq $32, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata,"a",@progbits
.Lcs29:
	.asciz "main"
.Lcs30:
	.asciz "?"
.Lcs38:
	.asciz "?"
