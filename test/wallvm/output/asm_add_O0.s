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
	movq $0x0000000000000028, (%rbx)
	movq (%rbx), %rax
	movl $0x0000000000000002, %ecx
	addq %rcx, %rax
	movq %rax, (%rbx)
	movq (%rbx), %rsi
	movq %rsi, %rax
	addq $24, %rsp
	popq %rbx
	leave
	ret
