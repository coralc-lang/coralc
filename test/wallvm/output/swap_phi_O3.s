.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	leaq -32(%rbp), %rsi
	movq $0x0000000000000001, %r9
	movq $0x0000000000000002, %r8
	movq $0x0000000000000000, %rsi
.L3:
	leaq 1(%rsi), %rdi
	cmpq $0x0000000000000004, %rdi
	jl .L21
.L4:
	movq $0x000000000000000a, %rsi
	imulq %r9, %rsi
	movq %r8, %rdi
	addq %rsi, %rdi
	movl %edi, %esi
	movq %rsi, %rax
	addq $32, %rsp
	leave
	ret
.L21:
	movq %rdi, %rsi
	movq %r9, %r11
	movq %r11, -16(%rbp)
	movq %r8, %r9
	movq -16(%rbp), %r8
	jmp .L3
