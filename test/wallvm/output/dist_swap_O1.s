.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	subq $152, %rsp
	leaq -96(%rbp), %rsi
	leaq -128(%rbp), %rdi
	leaq -160(%rbp), %r8
	leaq -192(%rbp), %r10
	movq %r10, -56(%rbp)
	leaq (%rsi), %rbx
	movq $0x000000000000000a, (%rbx)
	leaq 8(%rsi), %rbx
	movq $0x0000000000000014, (%rbx)
	leaq (%rdi), %rbx
	movq $0x0000000000000001, (%rbx)
	leaq 8(%rdi), %rbx
	movq $0x0000000000000002, (%rbx)
	movq $0x0000000000000000, %rbx
.L3:
	movl $0x0000000000000002, %r11d
	cmpq %r11, %rbx
	setl %r11b
	movzbq %r11b, %r12
	leaq (%rsi, %rbx, 8), %r13
	leaq (%rdi, %rbx, 8), %r14
	movq (%r13), %r15
	movq (%r14), %r9
	movq %r15, (%r14)
	movq %r9, (%r13)
	testq %r12, %r12
	je .L5
.L4:
	incq %rbx
	jmp .L3
.L5:
	movq $0x0000000000000000, %r9
.L6:
	movl $0x0000000000000002, %r11d
	cmpq %r11, %r9
	setl %r11b
	movzbq %r11b, %rbx
	leaq (%rsi, %r9, 8), %r12
	movq (%r12), %r13
	addq $0x000000000000000a, %r13
	leaq (%r8, %r9, 8), %r12
	movq %r13, (%r12)
	leaq (%rdi, %r9, 8), %r12
	movq (%r12), %r13
	addq $0x0000000000000014, %r13
	movq -56(%rbp), %r10
	leaq (%r10, %r9, 8), %r12
	movq %r13, (%r12)
	testq %rbx, %rbx
	je .L8
.L7:
	incq %r9
	jmp .L6
.L8:
	leaq 8(%rsi), %rdi
	movq (%rdi), %rsi
	leaq 8(%r8), %rdi
	movq (%rdi), %r8
	movq -56(%rbp), %r10
	leaq 8(%r10), %rdi
	movq (%rdi), %r9
	addq %r8, %rsi
	addq %rsi, %r9
	movq %r9, %rax
	addq $152, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
