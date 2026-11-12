.section .text
.globl nest
.type nest, @function
nest:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	subq $40, %rsp
	subq $8, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %r11
	movq %r11, -56(%rbp)
	addq $8, %rsp
	movq $0x0000000000000000, %rdi
	movq $0x0000000000000000, %r8
	movq $0x0000000000000000, %r9
.L4:
	cmpq $0x0000000000000003, %rdi
	jge .L13
.L5:
	movq $0x0000000000000000, %rbx
	movq $0x0000000000000000, %r12
.L6:
.L7:
	cmpq $0x0000000000000007, -56(%rbp)
	jne .L9
.L8:
	movq %r12, -72(%rbp)
	incq -72(%rbp)
	movq -72(%rbp), %r14
	jmp .L10
.L9:
	movq %r12, %r15
	addq $0x0000000000000002, %r15
	movq %r15, %r14
.L10:
.L11:
	movq %rbx, %rsi
	incq %rsi
	cmpq $0x0000000000000004, %rsi
	jl .L54
.L12:
	movq %rdi, %r13
	incq %r13
	movq %r13, %rdi
	movq %rbx, %r8
	movq %r12, %r9
	jmp .L4
.L13:
	leaq (%r8,%r8,4), %r8
	addq %r8, %r8
	addq %r8, %rdi
	addq %rdi, %r9
	movq %r9, %rax
	addq $40, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.L54:
	movq %rsi, %rbx
	movq %r14, %r12
	jmp .L6
.globl main
.type main, @function
main:
	movq $0x0000000000000007, %rdi
	call nest
	movq %rax, %rsi
	movq %rsi, %rax
	ret
