.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	subq $16, %rsp
	leaq -32(%rbp), %rbx
	movq %rbx, %r12
.L3:
	movq $0x0000000000000001, %rdi
	movq %r12, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs19(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq (%r12), %rsi
	cmpq $0x0000000000000007, %rsi
	jge .L5
.L4:
	movq $0x0000000000000007, (%r12)
	jmp .L3
.L5:
	movq %rsi, %rax
	addq $16, %rsp
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs19:
	.asciz "?"
