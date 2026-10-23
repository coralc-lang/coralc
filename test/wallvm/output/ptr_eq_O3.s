.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %r13
	subq $40, %rsp
.Lmain_entry_2:
	leaq -24(%rbp), %r8
	leaq -40(%rbp), %rsi
	movabsq $0x0000000000000001, %r10
	movl %r10d, (%r8)
	movabsq $0x0000000000000002, %r10
	movl %r10d, (%rsi)
	cmpq %rsi, %r8
	sete %r11b
	movzbq %r11b, %rdi
	movq %rdi, %rsi
	movq %rsi, %rax
	addq $40, %rsp
	popq %r13
	leave
	ret
