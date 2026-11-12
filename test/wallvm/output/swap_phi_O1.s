.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	leaq -32(%rbp), %rsi
	movq $0x0000000000000001, %rsi
	movq $0x0000000000000002, %rdi
	movq $0x0000000000000000, %r8
.L3:
	incq %r8
	cmpq $0x0000000000000004, %r8
	jl .L21
.L4:
	leaq (%rsi,%rsi,4), %rsi
	addq %rsi, %rsi
	addq %rsi, %rdi
	movq %rdi, %rax
	addq $32, %rsp
	leave
	ret
.L21:
	movq %rsi, %r11
	movq %r11, -16(%rbp)
	movq %rdi, %rsi
	movq -16(%rbp), %rdi
	jmp .L3
