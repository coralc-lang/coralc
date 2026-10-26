.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
.Lmain_entry_2:
	leaq -16(%rbp), %r8
	leaq -32(%rbp), %rsi
	movl $0x0000000000000001, %r10d
	movl %r10d, (%r8)
	movl $0x0000000000000002, %r10d
	movl %r10d, (%rsi)
	cmpq %rsi, %r8
	sete %r11b
	movzbq %r11b, %rdi
	movq %rdi, %rsi
	movq %rsi, %rax
	addq $32, %rsp
	leave
	ret
