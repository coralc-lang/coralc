.section .text
.globl nest
.type nest, @function
nest:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	subq $120, %rsp
	subq $8, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %r11
	movq %r11, -56(%rbp)
	addq $8, %rsp
	movq $0x0000000000000000, %r12
	movq $0x0000000000000000, %r11
	movq %r11, -88(%rbp)
	movq $0x0000000000000000, %r11
	movq %r11, -136(%rbp)
.L4:
	cmpq $0x0000000000000003, %r12
	jge .L13
.L5:
	movq $0x0000000000000000, %r15
	movq $0x0000000000000000, %rbx
.L6:
.L7:
	cmpq $0x0000000000000007, -56(%rbp)
	jne .L9
.L8:
	movq %rbx, -72(%rbp)
	incq -72(%rbp)
	movq %rbx, %rsi
	xorq -72(%rbp), %rsi
	movq -72(%rbp), %rdi
	xorq $0x0000000000000001, %rdi
	andq %rdi, %rsi
	movq %rsi, %r13
	movq $0x000000000000003f, %rcx
	sarq %cl, %r13
	movq $0x0000000000000003, %rdi
	movq %r13, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs55(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs54(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq -72(%rbp), %r11
	movq %r11, -104(%rbp)
	jmp .L10
.L9:
	movq %rbx, %r10
	addq $0x0000000000000002, %r10
	movq %r10, -120(%rbp)
	movq %rbx, %rsi
	xorq -120(%rbp), %rsi
	movq -120(%rbp), %rdi
	xorq $0x0000000000000002, %rdi
	andq %rdi, %rsi
	movq %rsi, %r13
	movq $0x000000000000003f, %rcx
	sarq %cl, %r13
	movq $0x0000000000000003, %rdi
	movq %r13, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs62(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs54(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq -120(%rbp), %r11
	movq %r11, -104(%rbp)
.L10:
.L11:
	movq %r15, -152(%rbp)
	incq -152(%rbp)
	movq %r15, %rsi
	xorq -152(%rbp), %rsi
	movq -152(%rbp), %rdi
	xorq $0x0000000000000001, %rdi
	andq %rdi, %rsi
	movq %rsi, %r14
	movq $0x000000000000003f, %rcx
	sarq %cl, %r14
	movq $0x0000000000000003, %rdi
	movq %r14, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs68(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs54(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	cmpq $0x0000000000000004, -152(%rbp)
	jl .L92
.L12:
	movq %r12, %r14
	incq %r14
	movq %r12, %rsi
	xorq %r14, %rsi
	movq %r14, %rdi
	xorq $0x0000000000000001, %rdi
	andq %rdi, %rsi
	movq %rsi, %r13
	movq $0x000000000000003f, %rcx
	sarq %cl, %r13
	movq $0x0000000000000003, %rdi
	movq %r13, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs74(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs54(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq %r14, %r12
	movq %r15, %r11
	movq %r11, -88(%rbp)
	movq %rbx, %r11
	movq %r11, -136(%rbp)
	jmp .L4
.L13:
	movq -88(%rbp), %r10
	leaq (%r10,%r10,4), %rsi
	addq %rsi, %rsi
	movq %rsi, %rbx
	addq %r12, %rbx
	xorq %rbx, %rsi
	xorq %rbx, %r12
	andq %r12, %rsi
	movq %rsi, %r12
	movq $0x000000000000003f, %rcx
	sarq %cl, %r12
	movq $0x0000000000000003, %rdi
	movq %r12, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs80(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs54(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq %rbx, %r12
	addq -136(%rbp), %r12
	xorq %r12, %rbx
	movq -136(%rbp), %rsi
	xorq %r12, %rsi
	andq %rsi, %rbx
	movq $0x000000000000003f, %rcx
	sarq %cl, %rbx
	movq $0x0000000000000003, %rdi
	movq %rbx, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs86(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs54(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq %r12, %rax
	addq $120, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.L92:
	movq -152(%rbp), %r15
	movq -104(%rbp), %rbx
	jmp .L6
.globl main
.type main, @function
main:
	movq $0x0000000000000007, %rdi
	call nest
	movq %rax, %rsi
	movq %rsi, %rax
	ret
.section .rodata,"a",@progbits
.Lcs54:
	.asciz "nest"
.Lcs55:
	.asciz "?"
.Lcs62:
	.asciz "?"
.Lcs68:
	.asciz "?"
.Lcs74:
	.asciz "?"
.Lcs80:
	.asciz "?"
.Lcs86:
	.asciz "?"
