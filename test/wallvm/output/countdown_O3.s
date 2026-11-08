.section .text
.globl main
.type main, @function
main:
	movq $0x000000000000000a, %r9
	movq $0x0000000000000000, %r8
.L3:
	cmpq $0x0000000000000000, %r9
	jle .L5
.L4:
	movq %r9, %rdi
	addq %r8, %rdi
	movq %r9, %rsi
	decq %rsi
	movq %rsi, %r9
	movq %rdi, %r8
	jmp .L3
.L5:
	movl %r8d, %esi
	movq %rsi, %rax
	ret
