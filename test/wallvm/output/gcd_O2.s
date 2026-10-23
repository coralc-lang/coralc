.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r14
	subq $40, %rsp
.Lmain_entry_2:
	leaq -24(%rbp), %rsi
	leaq -40(%rbp), %rdi
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
	movq (%rsi), %rbx
	movq %rbx, %rax
	cqo
	idivq %r8
	movq %rdx, %r12
	movq %r8, (%rsi)
	movq %r12, (%rdi)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%rsi), %rdi
	movl %edi, %r8d
	movq %r8, %rax
	addq $40, %rsp
	popq %r14
	popq %r12
	popq %rbx
	leave
	ret
