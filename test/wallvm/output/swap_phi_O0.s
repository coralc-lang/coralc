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
	leaq -64(%rbp), %rsi
	movq $0x0000000000000001, %rbx
	movq $0x0000000000000002, %r12
	movq $0x0000000000000000, %rsi
.L3:
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
	leaq .Lcs23(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs22(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	cmpq $0x0000000000000004, %r13
	jl .L37
.L4:
	leaq (%rbx,%rbx,4), %rbx
	addq %rbx, %rbx
	movq %rbx, %r13
	addq %r12, %r13
	xorq %r13, %rbx
	xorq %r13, %r12
	andq %r12, %rbx
	movq $0x000000000000003f, %rcx
	sarq %cl, %rbx
	movq $0x0000000000000003, %rdi
	movq %rbx, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs31(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs22(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq %r13, %rax
	addq $32, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.L37:
	movq %r13, %rsi
	movq %rbx, %r11
	movq %r11, -48(%rbp)
	movq %r12, %rbx
	movq -48(%rbp), %r12
	jmp .L3
.section .rodata,"a",@progbits
.Lcs22:
	.asciz "main"
.Lcs23:
	.asciz "?"
.Lcs31:
	.asciz "?"
