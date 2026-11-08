.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp
	leaq -16(%rbp), %r9
	movq %r9, %r8
.L3:
	movq (%r8), %rdi
	cmpq $0x0000000000000007, %rdi
	jge .L5
.L4:
	movq $0x0000000000000007, (%r8)
	jmp .L3
.L5:
	movl %edi, %esi
	movq %rsi, %rax
	addq $16, %rsp
	leave
	ret
