.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	leaq -16(%rbp), %rsi
	leaq -32(%rbp), %rdi
	movl $0x0000000000000001, (%rsi)
	movl $0x0000000000000002, (%rdi)
	cmpq %rdi, %rsi
	sete %r11b
	movzbq %r11b, %r8
	movq %r8, %rsi
	movq %rsi, %rax
	addq $32, %rsp
	leave
	ret
