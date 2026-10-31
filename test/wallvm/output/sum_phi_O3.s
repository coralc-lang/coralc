.section .text
.globl main
.type main, @function
main:
.Lmain_entry_2:
	movq $0x0000000000000000, %r9
	movq $0x0000000000000000, %r8
.Lmain_loop_3:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_done_5
.Lmain_body_4:
	movq %r9, %rdi
	addq %r8, %rdi
	movq $0x0000000000000001, %rsi
	addq %r9, %rsi
	movq %rsi, %r9
	movq %rdi, %r8
	jmp .Lmain_loop_3
.Lmain_done_5:
	movl %r8d, %esi
	movq %rsi, %rax
	ret
