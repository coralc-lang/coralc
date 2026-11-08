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
	subq $72, %rsp
	leaq -80(%rbp), %rbx
	leaq -96(%rbp), %r12
	leaq -112(%rbp), %r13
	movq $0x0000000000000000, (%rbx)
	movq $0x0000000000000001, (%r12)
	movq $0x0000000000000000, (%r13)
.L3:
	movq (%rbx), %rsi
	cmpq $0x000000000000000a, %rsi
	jge .L5
.L4:
	movq (%r12), %rsi
	movq (%r13), %r10
	movq %r10, -56(%rbp)
	movq %rsi, %r15
	addq -56(%rbp), %r15
	xorq %r15, %rsi
	movq -56(%rbp), %rdi
	xorq %r15, %rdi
	andq %rdi, %rsi
	movq %rsi, %r14
	movq $0x000000000000003f, %rcx
	sarq %cl, %r14
	movq $0x0000000000000003, %rdi
	movq %r14, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs32(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq -56(%rbp), %r10
	movq %r10, (%r12)
	movq %r15, (%r13)
	movq (%rbx), %rsi
	movq %rsi, %r14
	incq %r14
	xorq %r14, %rsi
	movq $0x0000000000000001, %rdi
	xorq %r14, %rdi
	andq %rdi, %rsi
	movq %rsi, %r15
	movq $0x000000000000003f, %rcx
	sarq %cl, %r15
	movq $0x0000000000000003, %rdi
	movq %r15, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs40(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	addq $0x0000000000000001, (%rbx)
	jmp .L3
.L5:
	movq (%r13), %rsi
	movq %rsi, %rax
	addq $72, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs32:
	.asciz "?"
.Lcs40:
	.asciz "?"
