.section .text
.globl main
.type main, @function
main:
.Lmain_entry_2:
	movq $0x0000000000000030, %rsi
	movq $0x0000000000000012, %rdi
.Lmain_loop_3:
	cmpq $0x0000000000000000, %rdi
	je .Lmain_done_5
.Lmain_body_4:
	movq %rsi, %rax
	cqo
	idivq %rdi
	movq %rdx, %r8
	movq %rdi, %rsi
	movq %r8, %rdi
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq %rsi, %rax
	ret
