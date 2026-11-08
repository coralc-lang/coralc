.section .text
.globl main
.type main, @function
main:
	pushq %rbx
	pushq %r12
	subq $8, %rsp
	movq g(%rip), %rsi
	movq %rsi, %rdi
	movq %rdi, %rbx
	incq %rbx
	xorq %rbx, %rdi
	movq $0x0000000000000001, %rsi
	xorq %rbx, %rsi
	andq %rsi, %rdi
	movq %rdi, %r12
	movq $0x000000000000003f, %rcx
	sarq %cl, %r12
	movq $0x0000000000000003, %rdi
	movq %r12, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs13(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %rbx, %rax
	addq $8, %rsp
	popq %r12
	popq %rbx
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs13:
	.asciz "?"
.section .data
	.balign 8
g:
	.quad 0x0000000000000006
