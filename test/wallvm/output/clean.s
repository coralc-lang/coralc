.section .text
.globl add
.type add, @function
add:
	subq $8, %rsp
	movq %rsi, 0(%rsp)
	movq 0(%rsp), %r8
	addq $8, %rsp
.Ladd_entry_4:
	movq %rdi, %rsi
	addq %r8, %rsi
	movq %rsi, %rax
	ret
.globl main
.type main, @function
main:
.Lmain_entry_8:
	movq $0x0000000000000014, %rdi
	movq $0x0000000000000016, %rsi
	call add
	movq %rax, %rsi
	movq %rsi, %rax
	ret
