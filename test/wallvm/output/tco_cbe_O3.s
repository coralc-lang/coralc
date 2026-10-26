.section .text
.globl inf
.type inf, @function
inf:
	subq $176, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %rsi
	addq $176, %rsp
.Linf_entry_3:
.Linf_acc_loop_13:
.Linf_entry_16:
	jmp .Linf_acc_loop_13
.globl main
.type main, @function
main:
.Lmain_entry_8:
	movq $0x0000000000000000, %rax
	ret
