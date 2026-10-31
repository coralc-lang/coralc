.section .text
.globl main
.type main, @function
main:
.Lmain_entry_2:
	movq $0x0000000000000030, %r8
	movq $0x0000000000000012, %rdi
.Lmain_loop_3:
	cmpq $0x0000000000000000, %rdi
	je .Lmain_done_5
.Lmain_body_4:
	movq %r8, %rax
	cqo
	idivq %rdi
	movq %rdx, %rsi
	movq %rdi, %r8
	movq %rsi, %rdi
	jmp .Lmain_loop_3
.Lmain_done_5:
	movl %r8d, %esi
	movq %rsi, %rax
	ret
