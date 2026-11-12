.section .text
.globl main
.type main, @function
main:
	movq $0x0000000000000003, %rdi
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs19(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs18(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq $0x0000000000000009, %rax
	ret
.section .rodata,"a",@progbits
.Lcs18:
	.asciz "main"
.Lcs19:
	.asciz "?"
