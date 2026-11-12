.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $48, %rsp
	leaq -16(%rbp), %r9
	leaq -32(%rbp), %rsi
	leaq -48(%rbp), %r8
	movq $0x0000000000000000, (%r8)
	movq $0x0000000000000005, (%r9)
	movq $0x0000000000000001, (%rsi)
	movb $0x0000000000000001, (%rsi)
	movq (%rsi), %rdi
	cmpq $0x0000000000000000, %rdi
	jg .L4
.L3:
	movq $0x000000000000000a, (%r8)
	movq %r8, %rdi
	jmp .L5
.L4:
	movq $0x0000000000000014, (%r9)
	movq %r9, %rdi
.L5:
	movq (%rdi), %r8
	movq $0x000000000000001e, (%r9)
	movq (%rdi), %rsi
	movq %r8, %rdi
	addq %rsi, %rdi
	movl %edi, %esi
	movq %rsi, %rax
	addq $48, %rsp
	leave
	ret
