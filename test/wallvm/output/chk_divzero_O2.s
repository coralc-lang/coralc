.section .text
.globl main
.type main, @function
main:
.Lmain_entry_2:
	movl $0x0000000000000064, %r10d
	movl $0x0000000000000000, %r11d
	movq %r10, %rax
	cqo
	idivq %r11
	movq %rax, %rsi
	movq %rsi, %rax
	ret
