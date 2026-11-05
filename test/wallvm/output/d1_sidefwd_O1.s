.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp
.Lmain_entry_6:
	leaq -16(%rbp), %rsi
	movl $0x000000000000002a, (%rsi)
	movq %rsi, holder(%rip)
	movl input(%rip), %edi
	cmpl $0x0000000000000000, %edi
	jne .Lmain_head_8
.Lmain_side_7:
	movl $0x0000000000000063, (%rsi)
	movq $0x0000000000000000, %rax
	addq $16, %rsp
	leave
	ret
.Lmain_head_8:
	movl (%rsi), %edi
	movq %rdi, %rax
	addq $16, %rsp
	leave
	ret
.section .data
	.balign 8
holder:
	.long 0x0000000000000000
	.balign 4
input:
	.long 0x0000000000000001
