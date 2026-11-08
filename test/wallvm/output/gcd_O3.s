.section .text
.globl main
.type main, @function
main:
	movq $0x0000000000000030, %r8
	movq $0x0000000000000012, %rdi
.L3:
	cmpq $0x0000000000000000, %rdi
	je .L5
.L4:
	movq %r8, %rax
	cqo
	idivq %rdi
	movq %rdx, %rsi
	movq %rdi, %r8
	movq %rsi, %rdi
	jmp .L3
.L5:
	movl %r8d, %esi
	movq %rsi, %rax
	ret
