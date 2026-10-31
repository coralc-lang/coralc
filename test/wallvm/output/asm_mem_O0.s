.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	subq $32, %rsp
.Lmain_entry_2:
	leaq -32(%rbp), %rbx
	leaq -48(%rbp), %r12
	movq $0x0000000000000007, (%rbx)
	movq %rbx, %rcx
	movq (%rcx), %rax
addq $1, %rax
	movq %rax, (%r12)
	movq (%r12), %rsi
	movq %rsi, %rax
	addq $32, %rsp
	popq %r12
	popq %rbx
	leave
	ret
