.section .text
.globl inf
.type inf, @function
inf:
.Linf_entry_3:
	call inf
	movq %rax, %rsi
	addq %rdi, %rsi
	movq %rsi, %rax
	ret
.globl main
.type main, @function
main:
.Lmain_entry_8:
	movq $0x0000000000000000, %rax
	ret
