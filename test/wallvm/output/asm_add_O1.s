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
	movabsq $0x0000000000000028, %r10
	movq %r10, (%rbx)
	movq (%rbx), %rax
	movabsq $0x0000000000000002, %rcx
	addq %rcx, %rax
	movq %rax, (%rbx)
	movq (%rbx), %rsi
	movl %esi, %edi
	movq %rdi, %rax
	addq $24, %rsp
	popq %rbx
	leave
	ret
