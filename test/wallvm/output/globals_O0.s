.section .text
.globl main
.type main, @function
main:
	pushq %rbx
.Lmain_entry_7:
	movq counter(%rip), %rsi
	movq answer(%rip), %rdi
	addq %rdi, %rsi
	movq %rsi, counter(%rip)
	movq alias(%rip), %rbx
	leaq .Lcs18(%rip), %r11
	leaq .Lcs18(%rip), %r11
	leaq .Lcs18(%rip), %r11
	movq $0x0000000000000001, %rdi
	movq %rbx, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs18(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq (%rbx), %rsi
	movq %rsi, %rax
	popq %rbx
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs18:
	.byte 63
	.byte 0
.section .data
	.balign 8
counter:
	.quad 0x000000000000000a
	.balign 8
answer:
	.quad 0x000000000000002a
	.balign 8
alias:
	.quad counter
