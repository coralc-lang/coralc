.section .text
.globl main
.type main, @function
main:
.Lmain_entry_2:
	movq $0x0000000000000003, %rdi
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs11(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq $0x0000000000000003, %rdi
	movq $0x0000000000000001, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs19(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq $0x0000000000000000, %rax
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs11:
	.byte 63
	.byte 0
.Lcs19:
	.byte 63
	.byte 0
