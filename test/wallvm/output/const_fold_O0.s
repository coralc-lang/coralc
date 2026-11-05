.section .text
.globl main
.type main, @function
main:
.Lmain_entry_2:
	movq $0x0000000000000003, %rdi
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs15(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq $0x0000000000000003, %rdi
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs22(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq $0x0000000000000007, %rax
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs15:
	.byte 63
	.byte 0
.Lcs22:
	.byte 63
	.byte 0
