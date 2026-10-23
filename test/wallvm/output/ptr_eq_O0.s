.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
.Lmain_entry_2:
	leaq -16(%rbp), %rsi
	leaq -32(%rbp), %rdi
	movabsq $0x0000000000000001, %r10
	movl %r10d, (%rsi)
	movabsq $0x0000000000000002, %r10
	movl %r10d, (%rdi)
	cmpq %rdi, %rsi
	sete %r11b
	movzbq %r11b, %r8
	movq %r8, %r9
	movq %r9, %rax
	addq $32, %rsp
	leave
	ret
