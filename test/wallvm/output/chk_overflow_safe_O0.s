.section .text
.globl main
.type main, @function
main:
	movq $0x0000000000000003, %rdi
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs17(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs16(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq $0x0000000000000003, %rdi
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs25(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs16(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq $0x0000000000000003, %rdi
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs32(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs16(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq $0x0000000000000003, %rdi
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs38(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs16(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq $0x0000000000000003, %rdi
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs44(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs16(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq $0x0000000000000000, %rax
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs16:
	.asciz "main"
.Lcs17:
	.asciz "?"
.Lcs25:
	.asciz "?"
.Lcs32:
	.asciz "?"
.Lcs38:
	.asciz "?"
.Lcs44:
	.asciz "?"
