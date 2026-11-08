.section .text
.globl main
.type main, @function
main:
	movq $0x0000000000000030, %rsi
	movq $0x0000000000000012, %rdi
.L3:
	cmpq $0x0000000000000000, %rdi
	je .L5
.L4:
	movq %rsi, %rax
	cqo
	idivq %rdi
	movq %rdx, %r8
	movq %rdi, %rsi
	movq %r8, %rdi
	jmp .L3
.L5:
	movq %rsi, %rax
	ret
