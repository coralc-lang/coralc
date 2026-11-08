.section .text
.globl main
.type main, @function
main:
	pushq %rbx
	leaq msg+1(%rip), %rsi
	leaq msg(%rip), %r11
	movq %r11, first(%rip)
	movb msg(%rip), %bl
	movb msg+1(%rip), %r8b
	movq first(%rip), %rdi
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
	.asciz "abc"
.section .data
	.balign 8
first:
	.quad 0x0000000000000000
