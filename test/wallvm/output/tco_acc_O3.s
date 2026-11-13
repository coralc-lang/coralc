.section .text
.globl sumto
.type sumto, @function
sumto:
	pushq %rbx
	pushq %r12
	subq $8, %rsp
	subq $8, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %rsi
	addq $8, %rsp
	movq $0x0000000000000000, %r12
	movq %rsi, %rbx
.L23:
.L26:
	movq %rbx, %r9
	decq %r9
	movq %r12, %r8
	addq %rbx, %r8
	cmpq $0x0000000000000000, %rbx
	jg .L54
.L27:
	movq %r12, %rax
	addq $8, %rsp
	popq %r12
	popq %rbx
	ret
.L54:
	movq %r8, %r12
	movq %r9, %rbx
	jmp .L23
.globl main
.type main, @function
main:
	pushq %rbx
	movq $0x0000000000000000, %rbx
	movq $0x0000000000000005, %r9
.L40:
.L41:
	movq %r9, %r8
	decq %r8
	movq %rbx, %rdi
	addq %r9, %rdi
	cmpq $0x0000000000000000, %r9
	jg .L60
.L38:
	movl %ebx, %esi
	movq %rsi, %rax
	popq %rbx
	ret
.L60:
	movq %rdi, %rbx
	movq %r8, %r9
	jmp .L40
