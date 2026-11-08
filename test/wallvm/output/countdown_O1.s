.section .text
.globl main
.type main, @function
main:
	movq $0x000000000000000a, %rsi
	movq $0x0000000000000000, %rdi
.L3:
	cmpq $0x0000000000000000, %rsi
	jle .L5
.L4:
	movq %rsi, %r8
	addq %rdi, %r8
	decq %rsi
	movq %r8, %rdi
	jmp .L3
.L5:
	movq %rdi, %rax
	ret
