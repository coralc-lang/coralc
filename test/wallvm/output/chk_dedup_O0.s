.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	subq $64, %rsp
	leaq -64(%rbp), %rbx
	leaq -80(%rbp), %rsi
	movq $0x0000000000000000, (%rsi)
	movq (%rsi), %r12
	movq $0x0000000000000000, %rdi
	movq %r12, %rsi
	movq $0x0000000000000005, %rdx
	leaq .Lcs21(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	leaq (%rbx, %r12, 8), %rsi
	movq $0x0000000000000001, (%rsi)
.L3:
	leaq (%rbx, %r12, 8), %rsi
	movq $0x0000000000000001, (%rsi)
	leaq (%rbx, %r12, 8), %rsi
	movq $0x0000000000000001, (%rsi)
	movq $0x0000000000000000, %rax
	addq $64, %rsp
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs21:
	.asciz "?"
