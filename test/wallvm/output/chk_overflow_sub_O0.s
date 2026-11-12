.section .text
.globl main
.type main, @function
main:
	movq $0x0000000000000003, %rdi
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs12(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs11(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq $0x0000000000000003, %rdi
	movq $0x00000000ffffffff, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs20(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs11(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq $0x000000007fffffff, %rax
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs11:
	.asciz "main"
.Lcs12:
	.asciz "?"
.Lcs20:
	.asciz "?"
