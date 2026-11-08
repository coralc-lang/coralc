.section .text
.globl main
.type main, @function
main:
	leaq msg(%rip), %rsi
	leaq msg+1(%rip), %rdi
	movq %rsi, first(%rip)
	movb msg(%rip), %r8b
	movb msg+1(%rip), %sil
	movq first(%rip), %rdi
	movq %rdi, %r9
	leaq 2(%r9), %rdi
	movb (%rdi), %r9b
	movzbl %r8b, %edi
	movzbl %sil, %r8d
	movzbl %r9b, %esi
	xorq %r8, %rdi
	xorq %rdi, %rsi
	movq %rsi, %rax
	ret
.section .rodata.str1.1,"aM",@progbits,1
msg:
	.asciz "abc"
.section .data
	.balign 8
first:
	.quad 0x0000000000000000
