.section .text
.globl main
.type main, @function
main:
.Lmain_entry_5:
	leaq msg(%rip), %rsi
	leaq msg+1(%rip), %rdi
	leaq first(%rip), %rdx
	movq %rsi, (%rdx)
	leaq msg(%rip), %rdx
	movb (%rdx), %r8b
	leaq msg+1(%rip), %rdx
	movb (%rdx), %sil
	leaq first(%rip), %rdx
	movq (%rdx), %rdi
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
	.byte 97, 98, 99
	.byte 0
.section .data
	.balign 8
first:
	.quad 0x0000000000000000
