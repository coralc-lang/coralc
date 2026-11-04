.section .text
.globl main
.type main, @function
main:
	pushq %rbx
.Lmain_entry_4:
	movq z(%rip), %rbx
	leaq .Lcs10(%rip), %r11
	leaq .Lcs10(%rip), %r11
	leaq .Lcs10(%rip), %r11
	movq $0x0000000000000001, %rdi
	movq %rbx, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs10(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq (%rbx), %rsi
	movq %rsi, %rax
	popq %rbx
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs10:
	.byte 63
	.byte 0
.section .data
	.balign 8
z:
	.quad 0x0000000000000000
