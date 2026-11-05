.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp
.Lmain_entry_2:
	leaq -16(%rbp), %r8
	leaq 8(%r8), %rsi
	movl $0x0000000000000007, (%r8)
	movq $0x0000000000000032, (%rsi)
	movl (%r8), %edi
	movl %edi, %esi
	leaq 50(%rsi), %rdi
	movl %edi, %esi
	movq %rsi, %rax
	addq $16, %rsp
	leave
	ret
