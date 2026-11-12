.section .text
.globl sumto
.type sumto, @function
sumto:
	pushq %rbx
	pushq %r12
	subq $8, %rsp
	subq $8, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %rbx
	addq $8, %rsp
	cmpq $0x0000000000000000, %rbx
	jg .L5
.L4:
	movq $0x0000000000000000, %rax
	addq $8, %rsp
	popq %r12
	popq %rbx
	ret
.L5:
	movq %rbx, %r12
	decq %r12
	movq %r12, %rdi
	call sumto
	movq %rax, %rsi
	addq %rbx, %rsi
	movq %rsi, %rax
	addq $8, %rsp
	popq %r12
	popq %rbx
	ret
.globl main
.type main, @function
main:
	movq $0x0000000000000005, %rdi
	call sumto
	movq %rax, %rsi
	movq %rsi, %rax
	ret
