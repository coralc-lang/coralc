.section .text
.globl fib
.type fib, @function
fib:
	pushq %rbx
	pushq %r12
	pushq %r13
	cmpq $0x0000000000000002, %rdi
	jge .L5
.L4:
	movq %rdi, %rax
	popq %r13
	popq %r12
	popq %rbx
	ret
.L5:
	movq %rdi, %rbx
	decq %rbx
	movq %rdi, %r12
	subq $0x0000000000000002, %r12
	movq %rbx, %rdi
	call fib
	movq %rax, %r13
	movq %r12, %rdi
	call fib
	movq %rax, %rsi
	addq %rsi, %r13
	movq %r13, %rax
	popq %r13
	popq %r12
	popq %rbx
	ret
.globl main
.type main, @function
main:
	pushq %rbx
.L29:
	movq $0x0000000000000009, %rdi
	call fib
	movq %rax, %rbx
	movq $0x0000000000000008, %rdi
	call fib
	movq %rax, %rsi
	addq %rsi, %rbx
	movq %rbx, %rsi
	jmp .L40
.L26:
	movl %esi, %edi
	movq %rdi, %rax
	popq %rbx
	ret
.L40:
	jmp .L26
