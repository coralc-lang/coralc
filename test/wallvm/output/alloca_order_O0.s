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
	movq $0x0000000000000007, (%rsi)
	movq $0x0000000000000003, (%rdi)
	movq (%rdi), %rsi
	movq %rsi, %rax
	addq $64, %rsp
	leave
	ret
