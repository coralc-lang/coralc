.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp
.Lmain_entry_2:
	leaq -16(%rbp), %r9
	movq %r9, %r8
.Lmain_loop_3:
	movq (%r8), %rdi
	cmpq $0x0000000000000007, %rdi
	jge .Lmain_done_5
.Lmain_body_4:
	movq $0x0000000000000007, (%r8)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movl %edi, %esi
	movq %rsi, %rax
	addq $16, %rsp
	leave
	ret
