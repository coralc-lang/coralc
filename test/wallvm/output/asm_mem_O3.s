.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	subq $32, %rsp
	leaq -32(%rbp), %r12
	leaq -48(%rbp), %rbx
	movq $0x0000000000000007, (%r12)
	movq %r12, %rcx
	movq (%rcx), %rax
addq $1, %rax
	movq %rax, (%rbx)
	movq (%rbx), %rdi
	movl %edi, %esi
	movq %rsi, %rax
	addq $32, %rsp
	popq %r12
	popq %rbx
	leave
	ret
