.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $24, %rsp
.Lmain_entry_2:
	leaq -32(%rbp), %rbx
	movl $0x0000000000000028, %r10d
	movq %r10, (%rbx)
	movl $0x0000000000000028, %eax
	addq $0x0000000000000002, %rax
	movq %rax, (%rbx)
	movq (%rbx), %rsi
	movq %rsi, %rax
	addq $24, %rsp
	popq %rbx
	leave
	ret
