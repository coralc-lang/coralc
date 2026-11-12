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
	pushq %r15
	subq $88, %rsp
	leaq -96(%rbp), %rbx
	leaq -112(%rbp), %r12
	movq $0x0000000000000000, (%r12)
.L3:
	movq (%r12), %rsi
	cmpq $0x0000000000000005, %rsi
	jge .L5
.L4:
	movq (%r12), %r13
	movq $0x0000000000000000, %rdi
	movq %r13, %rsi
	movq $0x0000000000000005, %rdx
	leaq .Lcs49(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs48(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	leaq (%rbx, %r13, 8), %r14
	movq %r13, %r15
	incq %r15
	xorq %r15, %r13
	movq %r15, %rsi
	xorq $0x0000000000000001, %rsi
	andq %rsi, %r13
	movq $0x000000000000003f, %rcx
	sarq %cl, %r13
	movq $0x0000000000000003, %rdi
	movq %r13, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs51(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs48(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq %r15, (%r14)
	movq (%r12), %rsi
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
	leaq .Lcs59(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs48(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	addq $0x0000000000000001, (%r12)
	jmp .L3
.L5:
	movq $0x0000000000000000, (%r12)
	leaq -128(%rbp), %r13
	movq $0x0000000000000000, (%r13)
.L6:
	movq (%r12), %rsi
	cmpq $0x0000000000000005, %rsi
	jge .L8
.L7:
	movq (%r12), %r14
	movq $0x0000000000000000, %rdi
	movq %r14, %rsi
	movq $0x0000000000000005, %rdx
	leaq .Lcs65(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs48(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	leaq (%rbx, %r14, 8), %rsi
	movq (%rsi), %rdi
	movq (%r13), %rsi
	movq %rsi, %r14
	addq %rdi, %r14
	xorq %r14, %rsi
	xorq %r14, %rdi
	andq %rdi, %rsi
	movq %rsi, %r15
	movq $0x000000000000003f, %rcx
	sarq %cl, %r15
	movq $0x0000000000000003, %rdi
	movq %r15, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs67(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs48(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq %r14, (%r13)
	movq (%r12), %rsi
	movq %rsi, %r14
	incq %r14
	xorq %r14, %rsi
	movq %r14, %rdi
	xorq $0x0000000000000001, %rdi
	andq %rdi, %rsi
	movq %rsi, %r15
	movq $0x000000000000003f, %rcx
	sarq %cl, %r15
	movq $0x0000000000000003, %rdi
	movq %r15, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs73(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs48(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	addq $0x0000000000000001, (%r12)
	jmp .L6
.L8:
	movq (%r13), %rsi
	movq %rsi, %rax
	addq $88, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata,"a",@progbits
.Lcs48:
	.asciz "main"
.Lcs49:
	.asciz "?"
.Lcs51:
	.asciz "?"
.Lcs59:
	.asciz "?"
.Lcs65:
	.asciz "?"
.Lcs67:
	.asciz "?"
.Lcs73:
	.asciz "?"
