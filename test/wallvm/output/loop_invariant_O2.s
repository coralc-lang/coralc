.section .text
.globl main
.type main, @function
main:
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000000, %rdi
.L3:
	cmpq $0x000000000000000a, %rsi
	jge .L5
.L4:
	movq %rdi, %r8
	addq $0x0000000000000015, %r8
	incq %rsi
	movq %r8, %rdi
	jmp .L3
.L5:
	movq %rdi, %rax
	ret
