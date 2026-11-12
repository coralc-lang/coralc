.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $88, %rsp
	leaq -64(%rbp), %rsi
	leaq -80(%rbp), %rdi
	movq $0x0000000000000000, (%rdi)
.L3:
	movq (%rdi), %r8
	cmpq $0x0000000000000005, %r8
	jge .L5
.L4:
	movq (%rdi), %r8
	leaq (%rsi, %r8, 8), %r9
	incq %r8
	movq %r8, (%r9)
	movq (%rdi), %r8
	addq $0x0000000000000001, (%rdi)
	jmp .L3
.L5:
	movq $0x0000000000000000, (%rdi)
	leaq -96(%rbp), %r8
	movq $0x0000000000000000, (%r8)
.L6:
	movq (%rdi), %r9
	cmpq $0x0000000000000005, %r9
	jge .L8
.L7:
	movq (%rdi), %r9
	leaq (%rsi, %r9, 8), %rbx
	movq (%rbx), %r9
	movq (%r8), %rbx
	addq %r9, %rbx
	movq %rbx, (%r8)
	movq (%rdi), %r9
	addq $0x0000000000000001, (%rdi)
	jmp .L6
.L8:
	movq (%r8), %rsi
	movq %rsi, %rax
	addq $88, %rsp
	popq %rbx
	leave
	ret
