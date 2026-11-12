.section .text
.globl main
.type main, @function
main:
	pushq %rbx
	movq z(%rip), %rbx
	movq $0x0000000000000001, %rdi
	movq %rbx, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs11(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs10(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq (%rbx), %rsi
	movq %rsi, %rax
	popq %rbx
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs10:
	.asciz "main"
.Lcs11:
	.asciz "?"
.section .data
	.balign 8
z:
	.quad 0x0000000000000000
