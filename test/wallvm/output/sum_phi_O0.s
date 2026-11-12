.section .text
.globl main
.type main, @function
main:
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	subq $8, %rsp
	movq $0x0000000000000000, %rbx
	movq $0x0000000000000000, %r12
.L3:
	cmpq $0x000000000000000a, %rbx
	jge .L5
.L4:
	movq %r12, %r13
	addq %rbx, %r13
	movq %r12, %rsi
	xorq %r13, %rsi
	movq %rbx, %rdi
	xorq %r13, %rdi
	andq %rdi, %rsi
	movq %rsi, %r14
	movq $0x000000000000003f, %rcx
	sarq %cl, %r14
	movq $0x0000000000000003, %rdi
	movq %r14, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs21(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs20(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq %rbx, %r14
	incq %r14
	xorq %r14, %rbx
	movq %r14, %rsi
	xorq $0x0000000000000001, %rsi
	andq %rsi, %rbx
	movq $0x000000000000003f, %rcx
	sarq %cl, %rbx
	movq $0x0000000000000003, %rdi
	movq %rbx, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs29(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs20(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq %r14, %rbx
	movq %r13, %r12
	jmp .L3
.L5:
	movq %r12, %rax
	addq $8, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	ret
.section .rodata,"a",@progbits
.Lcs20:
	.asciz "main"
.Lcs21:
	.asciz "?"
.Lcs29:
	.asciz "?"
