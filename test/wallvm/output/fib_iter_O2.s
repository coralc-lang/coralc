.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	leaq -32(%rbp), %rsi
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000001, %rdi
	movq $0x0000000000000000, %r8
.L3:
	cmpq $0x000000000000000a, %rsi
	jge .L5
.L4:
	addq %r8, %rdi
	incq %rsi
	movq %rdi, %r11
	movq %r11, -16(%rbp)
	movq %r8, %rdi
	movq -16(%rbp), %r8
	jmp .L3
.L5:
	movq %r8, %rax
	addq $32, %rsp
	leave
	ret
