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
	subq $64, %rsp
	leaq -80(%rbp), %rbx
	leaq -96(%rbp), %r12
	movq $0x0000000000000000, (%r12)
.L3:
	movq (%r12), %rsi
	cmpq $0x0000000000000007, %rsi
	jge .L5
.L4:
	movq (%r12), %r13
	movq $0x0000000000000000, %rdi
	movq %r13, %rsi
	movq $0x0000000000000005, %rdx
	leaq .Lcs28(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs27(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	leaq (%rbx, %r13, 8), %rsi
	movq $0x0000000000000001, (%rsi)
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
	leaq .Lcs30(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs27(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	addq $0x0000000000000001, (%r12)
	jmp .L3
.L5:
	movq $0x0000000000000000, %rax
	addq $64, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs27:
	.asciz "main"
.Lcs28:
	.asciz "?"
.Lcs30:
	.asciz "?"
