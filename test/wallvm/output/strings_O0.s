.section .text
.globl main
.type main, @function
main:
	pushq %rbx
	pushq %r12
	pushq %r13
.Lmain_entry_5:
	leaq msg(%rip), %rsi
	leaq msg+1(%rip), %rdi
	movq %rsi, first(%rip)
	movb msg(%rip), %bl
	movb msg+1(%rip), %r12b
	movq first(%rip), %rsi
	movq %rsi, %rdi
	leaq 2(%rdi), %r13
	movq $0x0000000000000001, %rdi
	movq %r13, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs26(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movb (%r13), %sil
	movzbl %bl, %edi
	movzbl %r12b, %r8d
	movzbl %sil, %r9d
	xorq %r8, %rdi
	xorq %r9, %rdi
	movq %rdi, %rax
	popq %r13
	popq %r12
	popq %rbx
	ret
.section .rodata.str1.1,"aM",@progbits,1
msg:
	.byte 97, 98, 99
	.byte 0
.Lcs26:
	.byte 63
	.byte 0
.section .data
	.balign 8
first:
	.quad 0x0000000000000000
