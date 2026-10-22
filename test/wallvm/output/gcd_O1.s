.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $80, %rsp
.Lmain_entry_2:
	leaq -64(%rbp), %rsi
	leaq -80(%rbp), %rdi
	movabsq $0x0000000000000030, %r10
	movq %r10, (%rsi)
	movabsq $0x0000000000000012, %r10
	movq %r10, (%rdi)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%rdi), %r8
	testq %r8, %r8
	setne %r11b
	movzbq %r11b, %r9
	testq %r9, %r9
	jne .Lmain_body_4
	jmp .Lmain_done_5
.Lmain_body_4:
	movq (%rsi), %r10
	movq %r10, -16(%rbp)
	movq (%rdi), %r10
	movq %r10, -32(%rbp)
	movq -16(%rbp), %rax
	cqo
	idivq -32(%rbp)
	movq %rdx, -48(%rbp)
	movq -32(%rbp), %r10
	movq %r10, (%rsi)
	movq -48(%rbp), %r10
	movq %r10, (%rdi)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%rsi), %rdi
	movl %edi, %r8d
	movq %r8, %rax
	addq $80, %rsp
	leave
	ret
