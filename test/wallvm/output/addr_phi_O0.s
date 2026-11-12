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
	leaq .Lcs20(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs19(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
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
.section .rodata,"a",@progbits
.Lcs19:
	.asciz "main"
.Lcs20:
	.asciz "?"
