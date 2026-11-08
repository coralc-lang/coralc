.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $56, %rsp
	leaq -64(%rbp), %rsi
	movq $0x0000000000000000, %rdi
.L3:
	cmpq $0x0000000000000005, %rdi
	jge .L5
.L4:
	leaq (%rsi, %rdi, 8), %r8
	incq %rdi
	movq %rdi, (%r8)
	jmp .L3
.L5:
	movq $0x0000000000000000, %rdi
	movq $0x0000000000000000, %r8
.L6:
	cmpq $0x0000000000000005, %rdi
	jge .L8
.L7:
	leaq (%rsi, %rdi, 8), %r9
	movq (%r9), %rbx
	addq %r8, %rbx
	incq %rdi
	movq %rbx, %r8
	jmp .L6
.L8:
	movq %r8, %rax
	addq $56, %rsp
	popq %rbx
	leave
	ret
