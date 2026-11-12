.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $48, %rsp
	leaq -48(%rbp), %rsi
	movq $0x0000000000000000, %rdi
.L3:
	cmpq $0x0000000000000007, %rdi
	jge .L5
.L4:
	leaq (%rsi, %rdi, 8), %r8
	movq $0x0000000000000001, (%r8)
	incq %rdi
	jmp .L3
.L5:
	movq $0x0000000000000000, %rax
	addq $48, %rsp
	leave
	ret
