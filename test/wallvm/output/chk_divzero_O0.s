.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $24, %rsp
	leaq -32(%rbp), %rsi
	movq $0x0000000000000000, (%rsi)
	movq (%rsi), %rbx
	movq $0x0000000000000002, %rdi
	movq %rbx, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs13(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs12(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movl $0x0000000000000064, %r10d
	movq %r10, %rax
	cqo
	idivq %rbx
	movq %rax, %rsi
	movq %rsi, %rax
	addq $24, %rsp
	popq %rbx
	leave
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs12:
	.asciz "main"
.Lcs13:
	.asciz "?"
