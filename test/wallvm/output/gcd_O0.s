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
	movq $0x0000000000000030, (%rbx)
	movq $0x0000000000000012, (%r12)
.L3:
	movq (%r12), %rsi
	cmpq $0x0000000000000000, %rsi
	je .L5
.L4:
	movq (%rbx), %r13
	movq (%r12), %r14
	movq $0x0000000000000002, %rdi
	movq %r14, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs28(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs27(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq %r13, %rax
	cqo
	idivq %r14
	movq %rdx, %rsi
	movq %r14, (%rbx)
	movq %rsi, (%r12)
	jmp .L3
.L5:
	movq (%rbx), %rsi
	movq %rsi, %rax
	addq $32, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata,"a",@progbits
.Lcs27:
	.asciz "main"
.Lcs28:
	.asciz "?"
