.section .text
.globl main
.type main, @function
main:
	pushq %rbx
.Lmain_entry_5:
	leaq msg+1(%rip), %rsi
	leaq msg(%rip), %r11
	leaq first(%rip), %rdx
	movq %r11, (%rdx)
	leaq msg(%rip), %rdx
	movb (%rdx), %bl
	leaq msg+1(%rip), %rdx
	movb (%rdx), %r8b
	leaq first(%rip), %rdx
	movq (%rdx), %rdi
	movq %rdi, %rsi
	leaq 2(%rsi), %rdi
	movb (%rdi), %sil
	movzbl %bl, %r9d
	movzbl %r8b, %edi
	movzbl %sil, %r8d
	movq %r9, %rsi
	xorq %rdi, %rsi
	movq %r8, %rdi
	xorq %rsi, %rdi
	movl %edi, %esi
	movq %rsi, %rax
	popq %rbx
	ret
.section .rodata.str1.1,"aM",@progbits,1
msg:
	.byte 97, 98, 99
	.byte 0
.section .data
	.balign 8
first:
	.quad 0x0000000000000000
