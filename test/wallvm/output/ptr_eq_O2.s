.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %r13
	subq $40, %rsp
.Lmain_entry_2:
	leaq -24(%rbp), %rsi
	leaq -40(%rbp), %rdi
	movabsq $0x0000000000000001, %r10
	movl %r10d, (%rsi)
	movabsq $0x0000000000000002, %r10
	movl %r10d, (%rdi)
	cmpq %rdi, %rsi
	sete %r11b
	movzbq %r11b, %r8
	movq %r8, %r9
	movq %r9, %rax
	addq $40, %rsp
	popq %r13
	leave
	ret
