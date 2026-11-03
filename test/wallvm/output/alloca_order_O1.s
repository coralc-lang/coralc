.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $48, %rsp
.Lmain_entry_2:
	leaq -48(%rbp), %rsi
	movq $0x0000000000000003, (%rsi)
	movq (%rsi), %rdi
	movq %rdi, %rax
	addq $48, %rsp
	leave
	ret
