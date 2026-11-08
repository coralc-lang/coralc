.section .text
.globl main
.type main, @function
main:
.Lmain_entry_4:
	movq seed(%rip), %rsi
	decq %rsi
	movq $0x0000000000000001, %rcx
	shlq %cl, %rsi
	movq %rsi, %rax
	ret
.section .data
	.balign 8
seed:
	.quad 0x0000000000000007
