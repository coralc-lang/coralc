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
	subq $16, %rsp
	leaq -48(%rbp), %rsi
	movq $0x0000000000000007, (%rsi)
	movq (%rsi), %rdi
	cmpq $0x0000000000000005, %rdi
	jle .L4
.L3:
	movq (%rsi), %rdi
	movq %rdi, %rbx
	movq $0x0000000000000001, %rcx
	shlq %cl, %rbx
	movq %rbx, %r12
	jmp .L5
.L4:
	movq (%rsi), %rdi
	movq %rdi, %r13
	negq %r13
	xorq $0x0000000000000000, %rdi
	movq %r13, %rsi
	xorq $0x0000000000000000, %rsi
	andq %rsi, %rdi
	movq %rdi, %r14
	movq $0x000000000000003f, %rcx
	sarq %cl, %r14
	movq $0x0000000000000003, %rdi
	movq %r14, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs26(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs25(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq %r13, %r12
.L5:
	movq %r12, %rax
	addq $16, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata,"a",@progbits
.Lcs25:
	.asciz "main"
.Lcs26:
	.asciz "?"
