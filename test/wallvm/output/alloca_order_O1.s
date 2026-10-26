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
	movl $0x0000000000000007, %r10d
	movq %r10, (%rsi)
	movl $0x0000000000000003, %r10d
	movq %r10, (%rdi)
	movq (%rdi), %rsi
	movq %rsi, %rax
	addq $64, %rsp
	leave
	ret
