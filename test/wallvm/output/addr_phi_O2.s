.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp
.Lmain_entry_2:
	leaq -16(%rbp), %rsi
	movq %rsi, %rdi
.Lmain_loop_3:
	movq (%rdi), %r8
	cmpq $0x0000000000000007, %r8
	jge .Lmain_done_5
.Lmain_body_4:
	movl $0x0000000000000007, %r10d
	movq %r10, (%rdi)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq %r8, %rax
	addq $16, %rsp
	leave
	ret
