.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $48, %rsp
	leaq -16(%rbp), %rsi
	leaq -32(%rbp), %rdi
	leaq -48(%rbp), %r8
	movq $0x0000000000000000, (%rsi)
	movq $0x0000000000000005, (%rdi)
	movq $0x0000000000000001, (%r8)
	movb $0x0000000000000001, (%r8)
	movq (%r8), %r9
	cmpq $0x0000000000000000, %r9
	jg .L4
.L3:
	movq $0x000000000000000a, (%rsi)
	movq %rsi, %r8
	jmp .L5
.L4:
	movq $0x0000000000000014, (%rdi)
	movq %rdi, %r8
.L5:
	movq (%r8), %rsi
	movq $0x000000000000001e, (%rdi)
	movq (%r8), %rdi
	addq %rdi, %rsi
	movq %rsi, %rax
	addq $48, %rsp
	leave
	ret
