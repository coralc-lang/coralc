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
	subq $184, %rsp
	leaq -128(%rbp), %rbx
	leaq -160(%rbp), %r10
	movq %r10, -88(%rbp)
	leaq -192(%rbp), %r10
	movq %r10, -72(%rbp)
	leaq -224(%rbp), %r10
	movq %r10, -56(%rbp)
	leaq (%rbx), %rsi
	movq $0x000000000000000a, (%rsi)
	leaq 8(%rbx), %rsi
	movq $0x0000000000000014, (%rsi)
	movq -88(%rbp), %r10
	leaq (%r10), %rsi
	movq $0x0000000000000001, (%rsi)
	movq -88(%rbp), %r10
	leaq 8(%r10), %rsi
	movq $0x0000000000000002, (%rsi)
	movq $0x0000000000000000, %r15
.L3:
	movl $0x0000000000000002, %r11d
	cmpq %r11, %r15
	setl %r11b
	movzbq %r11b, %r14
	movq $0x0000000000000000, %rdi
	movq %r15, %rsi
	movq $0x0000000000000003, %rdx
	leaq .Lcs67(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs66(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	leaq (%rbx, %r15, 8), %rsi
	movq -88(%rbp), %r10
	leaq (%r10, %r15, 8), %rdi
	movq (%rsi), %r8
	movq (%rdi), %r9
	movq %r8, (%rdi)
	movq %r9, (%rsi)
	testq %r14, %r14
	je .L5
.L4:
	movq %r15, %r14
	incq %r14
	xorq %r14, %r15
	movq %r14, %rsi
	xorq $0x0000000000000001, %rsi
	andq %rsi, %r15
	movq $0x000000000000003f, %rcx
	sarq %cl, %r15
	movq $0x0000000000000003, %rdi
	movq %r15, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs69(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs66(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq %r14, %r15
	jmp .L3
.L5:
	movq $0x0000000000000000, %r14
.L6:
	movl $0x0000000000000002, %r11d
	cmpq %r11, %r14
	setl %r11b
	movzbq %r11b, %r15
	movq $0x0000000000000000, %rdi
	movq %r14, %rsi
	movq $0x0000000000000003, %rdx
	leaq .Lcs76(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs66(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	leaq (%rbx, %r14, 8), %rsi
	movq (%rsi), %rdi
	movq %rdi, %r13
	addq $0x000000000000000a, %r13
	xorq %r13, %rdi
	movq %r13, %rsi
	xorq $0x000000000000000a, %rsi
	andq %rsi, %rdi
	movq %rdi, %r12
	movq $0x000000000000003f, %rcx
	sarq %cl, %r12
	movq $0x0000000000000003, %rdi
	movq %r12, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs78(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs66(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq -72(%rbp), %r10
	leaq (%r10, %r14, 8), %rsi
	movq %r13, (%rsi)
	movq -88(%rbp), %r10
	leaq (%r10, %r14, 8), %rsi
	movq (%rsi), %rdi
	movq %rdi, %r12
	addq $0x0000000000000014, %r12
	xorq %r12, %rdi
	movq %r12, %rsi
	xorq $0x0000000000000014, %rsi
	andq %rsi, %rdi
	movq %rdi, %r13
	movq $0x000000000000003f, %rcx
	sarq %cl, %r13
	movq $0x0000000000000003, %rdi
	movq %r13, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs84(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs66(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq -56(%rbp), %r10
	leaq (%r10, %r14, 8), %rsi
	movq %r12, (%rsi)
	testq %r15, %r15
	je .L8
.L7:
	movq %r14, %r12
	incq %r12
	xorq %r12, %r14
	movq %r12, %rsi
	xorq $0x0000000000000001, %rsi
	andq %rsi, %r14
	movq $0x000000000000003f, %rcx
	sarq %cl, %r14
	movq $0x0000000000000003, %rdi
	movq %r14, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs90(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs66(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq %r12, %r14
	jmp .L6
.L8:
	leaq 8(%rbx), %rsi
	movq (%rsi), %rdi
	movq -72(%rbp), %r10
	leaq 8(%r10), %rsi
	movq (%rsi), %r8
	movq -56(%rbp), %r10
	leaq 8(%r10), %rsi
	movq (%rsi), %rbx
	movq %rdi, %r12
	addq %r8, %r12
	xorq %r12, %rdi
	xorq %r12, %r8
	andq %r8, %rdi
	movq %rdi, %r13
	movq $0x000000000000003f, %rcx
	sarq %cl, %r13
	movq $0x0000000000000003, %rdi
	movq %r13, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs96(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs66(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq %r12, %r13
	addq %rbx, %r13
	xorq %r13, %r12
	xorq %r13, %rbx
	andq %rbx, %r12
	movq $0x000000000000003f, %rcx
	sarq %cl, %r12
	movq $0x0000000000000003, %rdi
	movq %r12, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs102(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs66(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq %r13, %rax
	addq $184, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata,"a",@progbits
.Lcs66:
	.asciz "main"
.Lcs67:
	.asciz "?"
.Lcs69:
	.asciz "?"
.Lcs76:
	.asciz "?"
.Lcs78:
	.asciz "?"
.Lcs84:
	.asciz "?"
.Lcs90:
	.asciz "?"
.Lcs96:
	.asciz "?"
.Lcs102:
	.asciz "?"
