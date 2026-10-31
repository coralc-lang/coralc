.section .text
.globl fib
.type fib, @function
fib:
	pushq %rbx
	pushq %r12
	pushq %r13
.Lfib_entry_3:
	cmpq $0x0000000000000002, %rdi
	jge .Lfib_rec_5
.Lfib_base_4:
	movq %rdi, %rax
	popq %r13
	popq %r12
	popq %rbx
	ret
.Lfib_rec_5:
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
.Lmain_entry_18:
	movq $0x000000000000000a, %rdi
	call fib
	movq %rax, %rsi
	movq %rsi, %rax
	ret
