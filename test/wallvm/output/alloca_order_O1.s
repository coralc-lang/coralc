.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $64, %rsp
.Lmain_entry_2:
	leaq -16(%rbp), %rsi
	leaq -64(%rbp), %rdi
	movabsq $0x0000000000000007, %r10
	movq %r10, (%rsi)
	movabsq $0x0000000000000003, %r10
	movq %r10, (%rdi)
	movq (%rdi), %r8
	movl %r8d, %r9d
	movq %r9, %rax
	addq $64, %rsp
	leave
	ret
