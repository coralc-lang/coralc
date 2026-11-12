.section .text
.globl main
.type main, @function
main:
	pushq %rbx
	pushq %r12
	subq $8, %rsp
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000000, %rdi
.L3:
	cmpq $0x0000000000000004, %rsi
	jge .L8
.L4:
	movq %rsi, %r8
	movq %rdi, %r9
	movq $0x0000000000000000, %rbx
.L5:
	cmpq $0x0000000000000003, %rbx
	jge .L7
.L6:
	movq %r8, %r12
	imulq %rbx, %r12
	addq %r9, %r12
	incq %rbx
	movq %r12, %r9
	jmp .L5
.L7:
	movq %r8, %rsi
	incq %rsi
	movq %r9, %rdi
	jmp .L3
.L8:
	movq %rdi, %rax
	addq $8, %rsp
	popq %r12
	popq %rbx
	ret
